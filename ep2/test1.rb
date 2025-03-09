class ADF
    def initialize(cadeia)
      @cadeia = cadeia.strip  # Remove espaços em branco no início e no final
      @indice = 0
      @max = @cadeia.size
      @resultado = ""
      @morse_code = {
        '.-' => 'a', '-...' => 'b', '-.-.' => 'c', '-..' => 'd', '.' => 'e', '..-.' => 'f', '--.' => 'g', '....' => 'h', '..' => 'i', '.---' => 'j',
        '-.-' => 'k', '.-..' => 'l', '--' => 'm', '-.' => 'n', '---' => 'o', '.--.' => 'p', '--.-' => 'q', '.-.' => 'r', '...' => 's', '-' => 't',
        '..-' => 'u', '...-' => 'v', '.--' => 'w', '-..-' => 'x', '-.--' => 'y', '--..' => 'z', '-----' => '0', '.----' => '1', '..---' => '2',
        '...--' => '3', '....-' => '4', '.....' => '5', '-....' => '6', '--...' => '7', '---..' => '8', '----.' => '9', '.-.-.-' => '.', '--..--' => ',',
        '-....-' => '-', '..--..' => '?'
      }
    end
  
    def proximo
      if @indice >= @max
        nil
      else
        @cadeia[@indice]
      end
    end
  
    def iniciar
      estado = "q0"
      morse_atual = ""
  
      puts "Máquina iniciou no estado: " + estado
  
      loop do
        simbolo = proximo
        break if simbolo.nil?
  
        case estado
        when "q0"  # Estado inicial
          if simbolo == '.' || simbolo == '-'
            morse_atual += simbolo
            estado = "q1"
          elsif simbolo == ' '  # Espaço separa palavras
            @resultado += " "
            estado = "q0"
          end
        when "q1"  # Construindo o código Morse
          if simbolo == '.' || simbolo == '-'
            morse_atual += simbolo
          elsif simbolo == ' '  # Espaço separa caracteres
            if @morse_code[morse_atual]
              @resultado += @morse_code[morse_atual]  # Traduz código Morse
              morse_atual = ""
            end
            estado = "q0"  # Retorna ao estado inicial
          end
        end
  
        @indice += 1
        puts "Estado: " + estado
        puts "Resultado: " + @resultado
      end
  
      # Verifica se há um caractere Morse restante ao final da cadeia
      if !morse_atual.empty? && @morse_code[morse_atual]
        @resultado += @morse_code[morse_atual]
      end
  
      puts "Resultado final: " + @resultado
    end
  end
  
  adf = ADF.new("-.-. --- -.. .. --. --- / -- --- .-. ... . / -.. . / . -..- . -- .--. .-.. ---")
  adf.iniciar