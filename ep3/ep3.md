# YAML Parser com Algoritmo de Earley e Avaliação de Expressões

Este projeto implementa um **parser de YAML simples** em Ruby utilizando o **algoritmo de Earley** para análise sintática. O sistema também suporta a **avaliação de expressões matemáticas** embutidas nos valores YAML, identificadas por cifrões (`$expressão$`).

## Funcionalidades

- Parser baseado no algoritmo de Earley.
- Suporte a tipos YAML: `string`, `number`, `boolean`, `null`.
- Suporte a expressões matemáticas com `+`, `-`, `*`, `/`, `()` e `^` (potência).
- Avaliação automática de expressões dentro de campos com a notação `$...$`.

## Estrutura do Código

### 1. Classe `Estado`

A classe `Estado` representa um estado do **algoritmo de Earley**. Cada estado contém:

- `regra`: a produção da gramática (por exemplo, `'PAIRS' => [['PAIR'], ['PAIR', 'PAIRS']]`).
- `ponto`: a posição atual na produção (onde o parser está).
- `inicio`: a posição de onde essa produção começou.

```ruby
class Estado
  attr_reader :regra, :ponto, :inicio

  def initialize(regra, ponto, inicio)
    @regra = regra
    @ponto = ponto
    @inicio = inicio
  end

  def simbolo_a_frente
    @regra[1][@ponto]
  end

  def avancar
    Estado.new(@regra, @ponto + 1, @inicio)
  end

  def completo?
    @ponto >= @regra[1].size
  end

  def to_s
    lhs = @regra[0]
    rhs = @regra[1]
    partes = rhs.dup.insert(@ponto, '•')
    "[#{lhs} → #{partes.join(' ')}, #{@inicio}]"
  end

  def ==(outro)
    outro.is_a?(Estado) && @regra == outro.regra && @ponto == outro.ponto && @inicio == outro.inicio
  end

  alias eql? ==
  def hash
    [@regra, @ponto, @inicio].hash
  end
end
```
#### Explicação: 

* Atributos: Guarda a regra da gramática, a posição atual da análise e a posição de início.

* Métodos principais: O simbolo_a_frente pega o próximo símbolo a ser analisado, e o avancar cria um novo estado com o ponto avançado. O método completo? verifica se a produção foi completada.

---
### 2. Gramática (GRAMATICA)
A gramática define como o parser deve estruturar e interpretar o YAML. A gramática inclui regras para os tipos básicos de dados YAML e expressões matemáticas.

```ruby
GRAMATICA = {
  'S' => [['PAIRS']],
  'PAIRS' => [['PAIR'], ['PAIR', 'PAIRS']],
  'PAIR' => [['KEY', ':', 'VALUE']],
  'KEY' => [['string']],
  'VALUE' => [['string'], ['number'], ['boolean'], ['null'], ['OBJETO'], ['LISTA'], ['CALC']],

  # Expressões matemáticas
  'CALC' => [['TERM'], ['TERM', '+', 'CALC'], ['TERM', '-', 'CALC']],
  'TERM' => [['FACTOR'], ['FACTOR', '*', 'TERM'], ['FACTOR', '/', 'TERM']],
  'FACTOR' => [['number'], ['(', 'CALC', ')']]
}
```
#### Explicação: 

Regras de gramática: Aqui definimos como os tipos de dados YAML são interpretados (strings, números, booleanos, null), além de incluir a parte da gramática para expressões matemáticas com as produções CALC, TERM, e FACTOR.

### 3. Função lexer
O lexer converte o texto YAML em uma lista de tokens. Ele usa expressões regulares para identificar diferentes componentes do YAML.

```ruby
def lexer(texto)
  tokens = []
  texto.each_line do |linha|
    linha.strip!
    next if linha.empty?
    if linha =~ /^([\w]+):\s*(.+)$/
      chave = $1
      valor = $2.strip
      tokens << [:string, chave]
      tokens << [":", ":"]

      # Tokeniza expressões matemáticas
      until valor.empty?
        case valor
        when /^(\d+)/
          tokens << [:number, $1]
          valor = valor[$1.size..].lstrip
        when /^(true|false)/
          tokens << [:boolean, $1]
          valor = valor[$1.size..].lstrip
        when /^null/
          tokens << [:null, 'null']
          valor = valor[4..].lstrip
        when /^"([^"]*)"/
          tokens << [:string, $1]
          valor = valor[$&.size..].lstrip
        when /^[\+\-\*\/\(\)]/
          tokens << [$&.to_sym, $&]
          valor = valor[1..].lstrip
        else
          tokens << [:string, valor]
          break
        end
      end
    end
  end
  tokens
end
```
#### Explicação:
Conversão em tokens: O lexer lê cada linha do arquivo YAML e divide os dados em tokens, como chaves (KEY), valores (VALUE), operadores matemáticos (+, -, *, /, ^) e parênteses.

### 1. Função earley_parse
Aqui ocorre a execução do algoritmo de Earley para realizar a análise sintática.

```ruby
def earley_parse(tokens, gramatica)
  chart = Array.new(tokens.size + 1) { Set.new }
  chart[0] << Estado.new(['S', ['PAIRS']], 0, 0)

  (0..tokens.size).each do |i|
    loop do
      tamanho_antes = chart[i].size

      chart[i].dup.each do |estado|
        if !estado.completo? && gramatica.key?(estado.simbolo_a_frente)
          gramatica[estado.simbolo_a_frente].each do |producao|
            chart[i] << Estado.new([estado.simbolo_a_frente, producao], 0, i)
          end
        elsif !estado.completo? && i < tokens.size && terminal?(estado.simbolo_a_frente)
          token = tokens[i]
          if simbolo_compatível?(estado.simbolo_a_frente, token)
            chart[i + 1] << estado.avancar
          end
        elsif estado.completo?
          chart[estado.inicio].each do |estado_antigo|
            if estado_antigo.simbolo_a_frente == estado.regra[0]
              chart[i] << estado_antigo.avancar
            end
          end
        end
      end

      break if chart[i].size == tamanho_antes
    end
  end

  chart.last.any? { |e| e.regra[0] == 'S' && e.completo? && e.inicio == 0 }
end
```
#### Explicação:
Algoritmo de Earley: O algoritmo realiza a análise sintática por meio de um conjunto de estados. A cada token lido, ele verifica se é possível expandir ou avançar com base nas produções da gramática.

Tabela de Earley (chart): Armazena os estados durante o processo de parsing.

### 5. Função avaliar_expressao
Após a validação do YAML, a função avaliar_expressao trata de expressões matemáticas encontradas no YAML.

```ruby
def avaliar_expressao(expr)
  expr.gsub!('^', '**') # Ruby usa ** para potência
  begin
    resultado = eval(expr)
    resultado
  rescue
    "Erro na expressão"
  end
end
```
#### Explicação:
Avaliação de expressões: A função substitui o símbolo ^ por ** (o operador de potência do Ruby) e usa o método eval para calcular o valor da expressão.

### 6. Fluxo do Script
O script realiza as seguintes etapas:

* Lê o conteúdo do arquivo YAML.
* Converte o YAML em tokens usando o lexer.
* Passa os tokens para o algoritmo de Earley para validação s intática.
* Se o YAML for válido, ele avalia as expressões matemáticas dentro d os valores YAML.
* Exibe os resultados de validação e das expressões matemáticas.

### 7. Exemplo de YAML aceito
Aqui está um exemplo de arquivo YAML:

```yaml
nome: João
idade: 30
ativo: true
conta: $9/3+21^1$
```
### Saida esperada
```makefile
Tokens: [[:string, "nome"], [":", ":"], [:string, "João"], [:string, "idade"], [":", ":"], [:number, "30"], [:string, "ativo"], [":", ":"], [:boolean, "true"], [:string, "conta"], [":", ":"], [:string, "$9/3+21^1$"]]

Resultado: YAML VÁLIDO

Avaliações:
conta: 24
```

Requisitos
Ruby (>= 2.5)

Nenhuma gem externa é necessária.