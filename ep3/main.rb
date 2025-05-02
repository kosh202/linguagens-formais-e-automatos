require 'yaml'

class SimpleYamlValidator
  CHAVE_REGEX = /^[a-zA-Z]+$/
  STRING_REGEX = /^[[:alpha:]\s]+$/u
  NUMERO_REGEX = /^[0-9]+$/
  BOOLEANOS = [true, false]
  NULO = nil

  def initialize(file_path)
    @data = YAML.load_file(file_path)
  end

  def parse
    return "Arquivo inválido!" unless @data.is_a?(Hash)

    @data.each do |chave, valor|
      return "Entrada inválida!" unless valida_chave(chave) && valida_valor(valor)
    end

    "Entrada válida!"
  end

  private

  def valida_chave(chave)
    chave.is_a?(String) && chave.match?(CHAVE_REGEX)
  end

  def valida_valor(valor)
    return true if valor.is_a?(String)  && valor.match?(STRING_REGEX)
    return true if valor.is_a?(Integer) && valor.to_s.match?(NUMERO_REGEX)
    return true if BOOLEANOS.include?(valor)
    return true if valor == NULO

    if valor.is_a?(Hash)
      valor.all? { |k, v| valida_chave(k) && valida_valor(v) }
    elsif valor.is_a?(Array)
      valor.all? { |item| valida_valor(item) }
    else
      false
    end
  end
end

# Exemplo de uso
parser = SimpleYamlValidator.new('test.yaml')
puts parser.parse
