require 'set'

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

# Gramática com expressões matemáticas
GRAMATICA = {
  'S' => [['PAIRS']],
  'PAIRS' => [['PAIR'], ['PAIR', 'PAIRS']],
  'PAIR' => [['KEY', ':', 'VALUE']],
  'KEY' => [['string']],
  'VALUE' => [['string'], ['number'], ['boolean'], ['null'], ['OBJETO'], ['LISTA'], ['CALC']],
  'CALC' => [['EXPR']],
  'EXPR' => [['TERM'], ['EXPR', '+', 'TERM'], ['EXPR', '-', 'TERM']],
  'TERM' => [['FACTOR'], ['TERM', '*', 'FACTOR'], ['TERM', '/', 'FACTOR']],
  'FACTOR' => [['number'], ['(', 'EXPR', ')'], ['FACTOR', '^', 'FACTOR']]
}

OPERADORES = %w[+ - * / ( ) ^]

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

      if valor.start_with?("$") && valor.end_with?("$")
        expressao = valor[1..-2].strip
        until expressao.empty?
          case expressao
          when /^\d+/
            tokens << [:number, $&]
            expressao = expressao[$&.size..].lstrip
          when /^[+\-*\/^()]/
            tokens << [$&.to_sym, $&]
            expressao = expressao[1..].lstrip
          else
            raise "Token inválido na expressão: #{expressao}"
          end
        end
      else
        case valor
        when /^(true|false)$/
          tokens << [:boolean, valor]
        when /^null$/
          tokens << [:null, valor]
        when /^"([^"]*)"$/
          tokens << [:string, $1]
        else
          tokens << [:string, valor]
        end
      end
    end
  end
  tokens
end

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

  # Impressão dos charts (opcional para debug)
  puts "\n--- CHART FINAL ---"
  chart.each_with_index do |conj, idx|
    puts "Chart[#{idx}]:"
    conj.each { |estado| puts "  #{estado}" }
  end

  chart.last.any? { |e| e.regra[0] == 'S' && e.completo? && e.inicio == 0 }
end

def terminal?(simbolo)
  ['string', 'number', 'boolean', 'null', ':', '+', '-', '*', '/', '(', ')', '^'].include?(simbolo.to_s)
end

def simbolo_compatível?(simbolo, token)
  simbolo.to_s == token[0].to_s || simbolo == token[1]
end

def avaliar_expressao(expr)
  expr.gsub!('^', '**')
  begin
    resultado = eval(expr)
    resultado
  rescue => e
    "Erro: #{e.message}"
  end
end

# Execução
yaml_path = 'test.yaml'
yaml_text = File.read(yaml_path)
tokens = lexer(yaml_text)
puts "Tokens: #{tokens.inspect}"

valido = earley_parse(tokens, GRAMATICA)
puts "\nResultado: #{valido ? 'YAML VÁLIDO' : 'YAML INVÁLIDO'}"

if valido
  puts "\nAvaliações:"
  yaml_text.each_line do |linha|
    linha.strip!
    if linha =~ /^([\w]+):\s*\$(.+)\$\s*$/
      chave = $1
      expressao = $2.strip
      puts "#{chave}: #{avaliar_expressao(expressao)}"
    end
  end
end
