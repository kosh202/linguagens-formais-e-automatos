# Função para reconhecer horário no formato "10:30", "às 10", "1 hora"
def reconhecer_horario(texto)
  horario_regex = /\b(às\s+)?(\d{1,2}:\d{2}|\d{1,2}\s*(hora|horas|h))\b/
  match = texto.match(horario_regex)
  if match
    puts "Horário reconhecido: #{match[0].strip}"
  else
    puts "Nenhum horário encontrado."
  end
end

# Função para reconhecer datas como "28 de Fevereiro", "13 de agosto de 2021", "30/01", "hoje", "amanhã"
def reconhecer_data(texto)
  # Regex para capturar datas no formato "22/12/2022" e outros formatos
  data_regex = /\b(\d{1,2}\/\d{1,2}\/\d{4}|\d{1,2}\s*(de\s*[a-zA-Z]+)\s*(de\s*\d{4})?|hoje|amanhã|depois\s+de\s+amanhã)\b/
  match = texto.match(data_regex)
  if match
    puts "Data reconhecida: #{match[0]}"
  else
    puts "Nenhuma data encontrada."
  end
end

# Função para reconhecer e-mails
def reconhecer_email(texto)
  email_regex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b/
  match = texto.match(email_regex)
  if match
    puts "E-mail reconhecido: #{match[0]}"
  else
    puts "Nenhum e-mail encontrado."
  end
end

# Função para reconhecer tags
def reconhecer_tag(texto)
  # Regex para capturar tags com caracteres especiais
  tag_regex = /#(\w|[a-zA-Záéíóúãõçâêîôûàèìòùãõâêîôûàèìòùç])+/
  match = texto.match(tag_regex)
  if match
    puts "Tag reconhecida: #{match[0]}"
  else
    puts "Nenhuma tag encontrada."
  end
end

# Função para reconhecer URLs
def reconhecer_url(texto)
  url_regex = /\bhttps?:\/\/[^\s]+/
  match = texto.match(url_regex)
  if match
    puts "URL reconhecida: #{match[0]}"
  else
    puts "Nenhuma URL encontrada."
  end
end

# Função para reconhecer ações com pessoas (como "agendar com José")
def reconhecer_acao_com_pessoa(texto)
  acao_regex = /(agendar|marcar|ligar|reunião)\s+com\s+([A-Za-zÀ-ÿ]+)/
  match = texto.match(acao_regex)
  if match
    puts "Ação: #{match[1]}"
    puts "Pessoa: #{match[2]}"
  else
    puts "Nenhuma ação com pessoa encontrada."
  end
end

# Função principal que junta todas as verificações
def processar_texto(texto)
  puts "\nProcessando: #{texto}"
  reconhecer_horario(texto)
  reconhecer_data(texto)
  reconhecer_email(texto)
  reconhecer_tag(texto)
  reconhecer_url(texto)
  reconhecer_acao_com_pessoa(texto)
  puts "----------------------------------"
end

# Testes com exemplos de entradas
entrada1 = "Agendar com José reunião às 10:00 amanhã #trabalho"
entrada2 = "Reunião com Maria, 28 de Fevereiro às 15:30"
entrada3 = "jose.da-silva@sp.senac.br"
entrada4 = "Vamos marcar com João para 1 hora"
entrada5 = "Visite nosso site em https://www.example.com para mais detalhes"
entrada6 = "Hoje é um ótimo dia para trabalhar! #motivação"
entrada7 = "Reunião marcada para 22/12/2022 às 10:00"

# Processar as entradas
processar_texto(entrada1)
processar_texto(entrada2)
processar_texto(entrada3)
processar_texto(entrada4)
processar_texto(entrada5)
processar_texto(entrada6)
processar_texto(entrada7)
