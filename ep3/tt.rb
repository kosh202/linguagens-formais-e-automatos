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
  
  # Gramática
  GRAMATICA = {
    'S' => [['PAIRS']],
    'PAIRS' => [['PAIR'], ['PAIR', 'PAIRS']],
    'PAIR' => [['KEY', ':', 'VALUE']],
    'KEY' => [['string']],
    'VALUE' => [['string'], ['number']]
  }
  
  # Lexer YAML
  def lexer(texto)
    tokens = []
    texto.each_line do |linha|
      linha.strip!
      next if linha.empty?
      if linha =~ /^(\w+):\s*(.+)$/
        chave = $1
        valor = $2.strip
        tokens << [:string, chave]
        tokens << [":", ":"]
        if valor =~ /^\d+$/
          tokens << [:number, valor]
        else
          tokens << [:string, valor]
        end
      end
    end
    tokens
  end
  
  # Earley Parser
  def earley_parse(tokens, gramatica)
    chart = Array.new(tokens.size + 1) { Set.new }
    chart[0] << Estado.new(['S', ['PAIRS']], 0, 0)
  
    (0..tokens.size).each do |i|
      loop do
        tamanho_antes = chart[i].size
  
        chart[i].dup.each do |estado|
          if !estado.completo? && gramatica.key?(estado.simbolo_a_frente)
            # Predict
            gramatica[estado.simbolo_a_frente].each do |producao|
              novo_estado = Estado.new([estado.simbolo_a_frente, producao], 0, i)
              chart[i] << novo_estado
            end
          elsif !estado.completo? && i < tokens.size && terminal?(estado.simbolo_a_frente)
            # Scan
            token = tokens[i]
            if estado.simbolo_a_frente.to_s == token[0].to_s
              chart[i + 1] << estado.avancar
            end
          elsif estado.completo?
            # Complete
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
  
    # Verificação final
    chart.last.any? { |e| e.regra[0] == 'S' && e.completo? && e.inicio == 0 }
  end
  
  def terminal?(simbolo)
    ['string', 'number', ':'].include?(simbolo)
  end
  
  # Ler arquivo YAML
  caminho = 'test.yaml'  # coloque o nome do seu arquivo .yaml aqui
  yaml_text = File.read(caminho)
  
  tokens = lexer(yaml_text)
  puts "Tokens: #{tokens.inspect}"
  
  require 'set'
  chart = earley_parse(tokens, GRAMATICA)
  
  puts "\nResultado: #{chart ? 'YAML VÁLIDO' : 'YAML INVÁLIDO'}"
  