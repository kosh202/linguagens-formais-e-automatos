class ADF
  def initialize(cadeia)
    @cadeia = cadeia
    @indice = 0
    @max = cadeia.size
    @resultado = ""  # Inicializa a variável resultado aqui
  end

  # pega apenas um caracter
  def proximo
    if @indice >= @max
      ""
    else
      @cadeia[@indice]
    end
  end
  
  def iniciar
    estado = "q0"
  
    puts "Máquina iniciou no estado: " + estado
  
    loop do
      simbolo = proximo
      case [simbolo, estado]
      in [".-", "q0"]
        estado = "q0"
        @resultado += "a"
      in ["-...", "q0"]
        estado = "q0"
        @resultado += "b"
      in [" ", "q0"]
        estado = "q0"
        @resultado += " "
      in ["/", "q0"]
        estado = "q1"
        puts "Aceito 😀"
        break
      else
        puts "Erro"
        break
      end
  
      @indice += 1
      puts "Estado: " + estado
      puts "Resultado: " + @resultado
    end
  end
end

adf = ADF.new("aabb")
adf.iniciar