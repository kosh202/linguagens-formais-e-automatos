class ADF
  def initialize(cadeia)
    @cadeia = cadeia
    @indice = 0
    @max = cadeia.size
    @letra = ""  # Inicializa a variável letra aqui
  end

  # Pega apenas um caracter
  def proximo
    if @indice >= @max
      ""
    else
      @cadeia[@indice]
    end
  end

  # Converte o código Morse para a letra correspondente
  def mosrseToletra(morse)
    # Tabela de correspondência entre Morse e letras
    morse_code = [
      [".-", "A"], ["-...", "B"], ["-.-.", "C"], ["-..", "D"], [".", "E"],
      ["..-.", "F"], ["--.", "G"], ["....", "H"], ["..", "I"], [".---", "J"],
      ["-.-", "K"], [".-..", "L"], ["--", "M"], ["-.", "N"], ["---", "O"],
      [".--.", "P"], ["--.-", "Q"], [".-.", "R"], ["...", "S"], ["-", "T"],
      ["..-", "U"], ["...-", "V"], [".--", "W"], ["-..-", "X"], ["-.--", "Y"],
      ["--..", "Z"]
    ]

    # Encontra a letra correspondente ao código Morse
    morse_entry = morse_code.find { |morse_pair| morse_pair[0] == morse }
    if morse_entry
      return morse_entry[1]  # Retorna a letra correspondente
    else
      return "?"  # Caso não encontre, retorna um caractere de erro
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
      in [".", "q0"]
        estado = "q0"
        morse += "."
      in ["-", "q0"]
        estado = "q0"
        morse += "-"
      in [" ", "q0"]
        estado = "q0"
        # Converte o código Morse acumulado em uma letra
        palavra += mosrseToletra(morse)
        morse = ""  # Reseta o código Morse para a próxima letra
      in ["/", "q0"]
        estado = "q0"
        # Finaliza a palavra (pode ser feito de acordo com a necessidade)
        palavra += " "
      else
        puts "Erro"
        break
      end
  
      @indice += 1
      puts "Estado atual: " + estado
      puts "Código Morse acumulado: " + morse
      puts "palavra: " + palavra
    end

    puts "Palavra resultante: " + palavra
  end
end

adf = ADF.new("-.-. --- -.. .. --. --- / -- --- .-. ... . / -.. . / . -..- . -- .--. .-.. --- ")
adf.iniciar
