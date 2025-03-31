# Explicação do Código

Este código tem como objetivo reconhecer e processar diferentes padrões de texto, como horários, datas, e-mails, tags, URLs e ações associadas a pessoas. Ele utiliza expressões regulares (regex) para identificar esses padrões em uma string de entrada.

## Funções

### 1. Função `reconhecer_horario`

```ruby
def reconhecer_horario(texto)
  horario_regex = /\b(às\s+)?(\d{1,2}:\d{2}|\d{1,2}\s*(hora|horas|h))\b/
  match = texto.match(horario_regex)
  if match
    puts "Horário reconhecido: #{match[0].strip}"
  else
    puts "Nenhum horário encontrado."
  end
end
```

- **Objetivo**: Identificar horários no formato `10:30`, `1 hora`, `às 10`, entre outros.
- **Regex usada**:
  - `\b(às\s+)?`: Opção de prefixo "às".
  - `(\d{1,2}:\d{2}|\d{1,2}\s*(hora|horas|h))`: Captura horários no formato "hh:mm" ou "h hora(s)".
- **Saída**: Exibe o horário reconhecido ou uma mensagem de erro caso não encontre nada.

### 2. Função `reconhecer_data`

```ruby
def reconhecer_data(texto)
  data_regex = /\b(\d{1,2}\/\d{1,2}\/\d{4}|\d{1,2}\s*(de\s*[a-zA-Z]+)\s*(de\s*\d{4})?|hoje|amanhã|depois\s+de\s+amanhã)\b/
  match = texto.match(data_regex)
  if match
    puts "Data reconhecida: #{match[0]}"
  else
    puts "Nenhuma data encontrada."
  end
end
```

- **Objetivo**: Reconhecer datas nos formatos `28/02/2022`, `13 de agosto de 2021`, `hoje`, `amanhã`, etc.
- **Regex usada**:
  - Captura datas no formato `dd/mm/yyyy`, `dd de mês de yyyy` e palavras-chave como `hoje`, `amanhã`, `depois de amanhã`.
- **Saída**: Exibe a data reconhecida ou uma mensagem de erro caso não encontre nada.

### 3. Função `reconhecer_email`

```ruby
def reconhecer_email(texto)
  email_regex = /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,7}\b/
  match = texto.match(email_regex)
  if match
    puts "E-mail reconhecido: #{match[0]}"
  else
    puts "Nenhum e-mail encontrado."
  end
end
```

- **Objetivo**: Identificar e-mails no formato padrão, como `jose.da-silva@exemplo.com`.
- **Regex usada**:
  - A regex padrão para e-mails: permite letras, números, pontos, hífens, e caracteres especiais antes do símbolo `@` e um domínio válido após.
- **Saída**: Exibe o e-mail reconhecido ou uma mensagem de erro caso não encontre nada.

### 4. Função `reconhecer_tag`

```ruby
def reconhecer_tag(texto)
  tag_regex = /#(\w|[a-zA-Záéíóúãõçâêîôûàèìòùãõâêîôûàèìòùç])+/ 
  match = texto.match(tag_regex)
  if match
    puts "Tag reconhecida: #{match[0]}"
  else
    puts "Nenhuma tag encontrada."
  end
end
```

- **Objetivo**: Identificar tags no formato `#tag`, como `#trabalho`, `#motivação`.
- **Regex usada**:
  - Captura uma palavra precedida por `#`, permitindo caracteres especiais como acentos e til.
- **Saída**: Exibe a tag reconhecida ou uma mensagem de erro caso não encontre nada.

### 5. Função `reconhecer_url`

```ruby
def reconhecer_url(texto)
  url_regex = /\bhttps?:\/\/[^\s]+/
  match = texto.match(url_regex)
  if match
    puts "URL reconhecida: #{match[0]}"
  else
    puts "Nenhuma URL encontrada."
  end
end
```

- **Objetivo**: Identificar URLs no formato `http://` ou `https://`.
- **Regex usada**:
  - Captura URLs iniciadas com `http://` ou `https://`, seguidas por qualquer sequência de caracteres não-espaços.
- **Saída**: Exibe a URL reconhecida ou uma mensagem de erro caso não encontre nada.

### 6. Função `reconhecer_acao_com_pessoa`

```ruby
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
```

- **Objetivo**: Identificar ações associadas a pessoas, como "agendar com João", "marcar com Maria".
- **Regex usada**:
  - Captura as ações `agendar`, `marcar`, `ligar` ou `reunião`, seguidas de "com" e o nome de uma pessoa (letras maiúsculas/minúsculas com acentos).
- **Saída**: Exibe a ação e a pessoa envolvida ou uma mensagem de erro caso não encontre nada.

### 7. Função Principal `processar_texto`

```ruby
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
```

- **Objetivo**: Processar um texto de entrada, passando-o por todas as funções de reconhecimento.
- **Saída**: Exibe os resultados de cada verificação (horário, data, e-mail, tag, URL, ação com pessoa).

### Testes

O código também inclui alguns exemplos de entradas para testar as funções:

```ruby
entrada1 = "Agendar com José reunião às 10:00 amanhã #trabalho"
entrada2 = "Reunião com Maria, 28 de Fevereiro às 15:30"
entrada3 = "jose.da-silva@sp.senac.br"
entrada4 = "Vamos marcar com João para 1 hora"
entrada5 = "Visite nosso site em https://www.example.com para mais detalhes"
entrada6 = "Hoje é um ótimo dia para trabalhar! #motivação"
entrada7 = "Reunião marcada para 22/12/2022 às 10:00"
```

Cada uma dessas entradas é processada pela função `processar_texto`, que chama todas as funções para identificar os padrões presentes no texto.

### Conclusão

Esse código utiliza expressões regulares para identificar horários, datas, e-mails, tags, URLs e ações relacionadas a pessoas em uma string de entrada. Ele pode ser expandido ou modificado para lidar com outros tipos de entrada ou para melhorar a detecção de padrões específicos.
