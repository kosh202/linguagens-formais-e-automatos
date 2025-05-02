# YAML Parser com Algoritmo de Earley e Avaliação de Expressões

Este projeto implementa um **parser de YAML simples** em Ruby utilizando o **algoritmo de Earley** para análise sintática. O sistema também suporta a **avaliação de expressões matemáticas** embutidas nos valores YAML, identificadas por cifrões (`$expressão$`).

## Funcionalidades

- Parser baseado no algoritmo de Earley.
- Suporte a tipos YAML: `string`, `number`, `boolean`, `null`.
- Suporte a expressões matemáticas com `+`, `-`, `*`, `/`, `()`, `^` (potência).
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

---

### 2. Gramática (GRAMATICA)

A gramática define como o parser deve estruturar e interpretar o YAML. A gramática inclui regras para os tipos básicos de dados YAML e expressões matemáticas.

```ruby
GRAMATICA = {
  'S' => [['PAIRS']],
  'PAIRS' => [['PAIR'], ['PAIR', 'PAIRS']],
  'PAIR' => [['KEY', ':', 'VALUE']],
  'KEY' => [['string']],
  'VALUE' => [['string'], ['number'], ['boolean'], ['null'], ['CALC']],
  'CALC' => [['EXP']],
  'EXP' => [['TERM'], ['TERM', '+', 'EXP'], ['TERM', '-', 'EXP']],
  'TERM' => [['FACTOR'], ['FACTOR', '*', 'TERM'], ['FACTOR', '/', 'TERM']],
  'FACTOR' => [['BASE'], ['BASE', '^', 'FACTOR']],
  'BASE' => [['number'], ['(', 'EXP', ')']]
}
```

---

### 3. Função `lexer`

O lexer converte o texto YAML em uma lista de tokens. Ele identifica valores comuns e expressões dentro de `$...$`.

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

      if valor.match(/^\$.*\$$/)
        expressao = valor[1..-2] # remove os cifrões
        until expressao.empty?
          case expressao
          when /^(\d+)/
            tokens << [:number, $1]
            expressao = expressao[$1.size..].lstrip
          when /^[+\-\*\/\^]/
            tokens << [$&.to_sym, $&]
            expressao = expressao[1..].lstrip
          when /^\(/
            tokens << ["(", "("]
            expressao = expressao[1..].lstrip
          when /^\)/
            tokens << [")", ")"]
            expressao = expressao[1..].lstrip
          else
            raise "Token inválido na expressão: #{expressao}"
          end
        end
      else
        if valor =~ /^\d+$/
          tokens << [:number, valor]
        elsif valor == 'true' || valor == 'false'
          tokens << [:boolean, valor]
        elsif valor == 'null'
          tokens << [:null, valor]
        else
          tokens << [:string, valor]
        end
      end
    end
  end
  tokens
end
```

---

### 4. Função `earley_parse`

Executa o algoritmo de Earley para validação sintática dos tokens.

```ruby
def earley_parse(tokens, gramatica)
  chart = Array.new(tokens.size + 1) { Set.new }
  chart[0] << Estado.new(['S', ['PAIRS']], 0, 0)

  (0..tokens.size).each do |i|
    loop do
      tamanho_antes = chart[i].size
      chart[i].dup.each do |estado|
        simbolo = estado.simbolo_a_frente

        if simbolo && gramatica.key?(simbolo)
          gramatica[simbolo].each do |producao|
            chart[i] << Estado.new([simbolo, producao], 0, i)
          end
        elsif simbolo && i < tokens.size && terminal?(simbolo)
          token = tokens[i]
          if simbolo_compatível?(simbolo, token)
            chart[i + 1] << estado.avancar
          end
        elsif estado.completo?
          chart[estado.inicio].each do |e|
            if e.simbolo_a_frente == estado.regra[0]
              chart[i] << e.avancar
            end
          end
        end
      end
      break if chart[i].size == tamanho_antes
    end
  end

  puts "\nCHART FINAL"
  chart.each_with_index do |conjunto, i|
    puts "\nChart[#{i}]"
    conjunto.each { |e| puts e }
  end

  chart.last.any? { |e| e.regra[0] == 'S' && e.completo? && e.inicio == 0 }
end
```

---

### 5. Função `avaliar_expressao`

Avalia expressões matemáticas extraídas de valores com `$...$`.

```ruby
def avaliar_expressao(expr)
  expr.gsub!('^', '**')
  begin
    eval(expr)
  rescue => e
    "Erro: #{e.message}"
  end
end
```

---

### 6. Execução do Script

```ruby
texto = File.read('exemplo.yaml')
tokens = lexer(texto)
puts "Tokens: #{tokens.inspect}"

if earley_parse(tokens, GRAMATICA)
  puts "\nResultado: YAML VÁLIDO"
  puts "\nAvaliações:"
  texto.each_line do |linha|
    if linha =~ /^([\w]+):\s*\$(.*)\$/
      chave = $1
      expr = $2
      puts "#{chave}: #{avaliar_expressao(expr)}"
    end
  end
else
  puts "\nResultado: YAML INVÁLIDO"
end
```

---

## Exemplo de YAML Aceito

```yaml
expressao_simples: $4 + 5$
expressao_prioridade: $4 + 5 * 2$
expressao_com_parenteses: $(4 + 5) * 2$
expressao_com_expoente: $2 ^ 3$
expressao_complexa: $(2 + 3) * (4 + 1) ^ 2$
```

### Saída Esperada

```bash
Tokens: [[:string, "expressao_simples"], [":", ":"], [:number, "4"], [:+, "+"], [:number, "5"], ...]

Resultado: YAML VÁLIDO

Avaliações:
expressao_simples: 9
expressao_prioridade: 14
expressao_com_parenteses: 18
expressao_com_expoente: 8
expressao_complexa: 125
```

---

## Requisitos

- Ruby (>= 2.5)
- Nenhuma gem externa é necessária.
