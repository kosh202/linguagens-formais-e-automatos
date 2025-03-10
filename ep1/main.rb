class MorseTranslator
  def initialize(cadeia)
    @cadeia = cadeia.split("")  # Divide a cadeia em caracteres
    @indice = 0
    @max = @cadeia.size
  end

  # Pega apenas um caracter da cadeia
  def proximo
    if @indice >= @max
      ""
    else
      @cadeia[@indice].tap { @indice += 1 }  # Incrementa o índice ao retornar o símbolo
    end
  end

  # Converte o código Morse acumulado para a letra correspondente
  def morseToletra(morse)
    case morse
    when ".-"
      "A"
    when "-..."
      "B"
    when "-.-."
      "C"
    when "-.."
      "D"
    when "."
      "E"
    when "..-."
      "F"
    when "--."
      "G"
    when "...."
      "H"
    when ".."
      "I"
    when ".---"
      "J"
    when "-.-"
      "K"
    when ".-.."
      "L"
    when "--"
      "M"
    when "-."
      "N"
    when "---"
      "O"
    when ".--."
      "P"
    when "--.-"
      "Q"
    when ".-."
      "R"
    when "..."
      "S"
    when "-"
      "T"
    when "..-"
      "U"
    when "...-"
      "V"
    when ".--"
      "W"
    when "-..-"
      "X"
    when "-.--"
      "Y"
    when "--.."
      "Z"
    when "-----"
      "0"
    when ".----"
      "1"
    when "..---"
      "2"
    when "...--"
      "3"
    when "....-"
      "4"
    when "....."
      "5"
    when "-...."
      "6"
    when "--..."
      "7"
    when "---.."
      "8"
    when "----."
      "9"
    when ".-.-.-"
      "."
    when "--..--"
      ","
    when "-....-"
      "-"
    when "..--.."
      "?"
    when " "
      ""
    when ""
      ""
    when "/"
      " "
    else
      "?"  # Caso não seja encontrado, retorna erro
    end
  end

  def iniciar
    estado = "q0"
    morse = ""
    palavra = ""

    puts "Máquina iniciou no estado: " + estado

    loop do
      simbolo = proximo
      case [simbolo, estado]
      when [".", "q0"]
        estado = "q1"
        morse += "."
      when ["-", "q0"]
        estado = "q0"
        morse += "-"
      when [" ", "q0"]
        palavra += morseToletra(morse)
        estado = "q0"
        morse = ""  # Reseta o código Morse para a próxima letra
      when ["-", "q1"]
        estado = "q0"
        morse += "-"
      when [".", "q1"]
        estado = "q1"
        morse += "."
      when [" ", "q1"]
        palavra += morseToletra(morse)
        estado = "q0"
        morse = ""  # Reseta o código Morse para a próxima letra
      when ["/", "q0"]
        estado = "q0"
        palavra += " "  # Adiciona espaço para separar palavras
      when ["", "q0"]
        palavra += morseToletra(morse)
        estado = "q2"
        morse = ""
      when ["", "q1"]
        palavra += morseToletra(morse)
        estado = "q2"
        morse = ""
      when ["", "q2"]
        estado = "q2"
        palavra += morseToletra(morse) unless morse.empty?
        break  # Termina quando a cadeia estiver vazia
      else
        puts "Erro"
        break
      end

      puts "Estado atual: " + estado
      puts "Código Morse acumulado: " + morse
      puts "Palavra: " + palavra
    end

    puts "Palavra resultante: " + palavra.strip  # Remove espaços em branco no final
  end
end

# Teste do Tradutor com uma sequência de Código Morse
adf = MorseTranslator.new(".- -... -.-. -.. . ..-. --. .... .. .--- -.- .-.. -- -. --- .--. --.- .-. ... - ..- ...- .-- -..- -.-- --.. ----- .---- ..--- ...-- ....- ..... -.... --... ---.. ----. .-.-.- --..-- -....- ..--..")
adf.iniciar