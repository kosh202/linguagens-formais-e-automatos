# ========= FUNÇÕES AUXILIARES =========

def extrair_bloco(str, idx, prefixo)
  bloco = ""
  if str[idx] == prefixo
    bloco += str[idx]
    idx += 1

    letras_validas = case prefixo
                    when 'f'
                      # Para estados, decidir qual letra aceitar depois do prefixo f
                      if idx < str.length
                        if str[idx] == 'a'
                          ['a']
                        elsif str[idx] == 'b'
                          ['b']
                        else
                          []
                        end
                      else
                        []
                      end
                    when 's'
                      ['c']
                    else
                      []
                    end

    while idx < str.length && letras_validas.include?(str[idx])
      bloco += str[idx]
      idx += 1
    end
  end
  bloco
end

def parse_maquina(cod)
  transicoes = {}
  estados_aceitacao = []
  estado_inicial = nil

  i = 0
  while i < cod.length
    estado_atual = extrair_bloco(cod, i, "f")
    i += estado_atual.length

    simbolo_lido = extrair_bloco(cod, i, "s")
    i += simbolo_lido.length

    estado_novo = extrair_bloco(cod, i, "f")
    i += estado_novo.length

    simbolo_novo = extrair_bloco(cod, i, "s")
    i += simbolo_novo.length

    direcao = cod[i]
    i += 1

    # Estado inicial é o primeiro estado lido
    estado_inicial ||= estado_atual

    # Estados de aceitação começam com fb
    estados_aceitacao << estado_novo if estado_novo.start_with?("fb")

    transicoes[[estado_atual, simbolo_lido]] = [estado_novo, simbolo_novo, direcao]
  end

  return transicoes, estado_inicial, estados_aceitacao
end

# def traduzir_fita(fita)
#   traducao = fita.map do |simbolo|
#     case simbolo
#     when 'sc'     then 'a'
#     when 'scc'    then 'b'
#     when 'sccc'   then 'c'
#     when '_'     then '␣'  # ou ' ' se preferir espaço
#     else '?'
#     end
#   end
#   traducao.join
# end
def traduzir_fita(fita)
  traducao = fita.map do |simbolo|
    if simbolo == '_'
      '␣'  # ou ' ' se preferir um espaço
    elsif simbolo.start_with?('s')
      # contar número de 'c's depois do 's'
      c_count = simbolo.count('c')
      # mapear para letras, começando em 'a'
      if c_count > 0 && c_count <= 26
        # código ASCII do 'a' é 97
        (97 + c_count - 1).chr
      else
        '?'
      end
    else
      '?'
    end
  end
  traducao.join
end



def mostrar_regras(cod)
  regras = []
  i = 0

  while i < cod.length
    estado_atual = extrair_bloco(cod, i, "f")
    i += estado_atual.length

    simbolo_lido = extrair_bloco(cod, i, "s")
    i += simbolo_lido.length

    estado_novo = extrair_bloco(cod, i, "f")
    i += estado_novo.length

    simbolo_novo = extrair_bloco(cod, i, "s")
    i += simbolo_novo.length

    direcao = cod[i]
    i += 1

    regras << "(#{estado_atual}, #{simbolo_lido}) => (#{estado_novo}, #{simbolo_novo}, #{direcao})"
  end

  puts "\n📜 REGRAS LIDAS (TRANSIÇÕES):"
  regras.each { |r| puts r }
end

# ========= FUNÇÃO PRINCIPAL =========

def executar_mtu(entrada)
  cod_maquina, fita_str = entrada.split("#")
  transicoes, estado_inicial, estados_aceitacao = parse_maquina(cod_maquina)

  fita = []
  i = 0
  while i < fita_str.length
    bloco = extrair_bloco(fita_str, i, "s")
    # Se bloco vazio (símbolo não reconhecido), tentar pegar '_' como branco
    if bloco.empty? && fita_str[i] == '_'
      bloco = '_'
      i += 1
    else
      i += bloco.length
    end
    fita << bloco
  end

  cabecote = 0
  estado = estado_inicial
  passo = 0

  loop do
    simbolo = fita[cabecote] || "_"  # símbolo branco se fora da fita
    chave = [estado, simbolo]

    puts "\n🧭 Passo #{passo}"
    puts "Estado atual: #{estado}"
    puts "Símbolo sob cabeçote: #{simbolo}"

    if transicoes.key?(chave)
      novo_estado, novo_simbolo, movimento = transicoes[chave]
      puts "→ Transição: (#{estado}, #{simbolo}) → (#{novo_estado}, #{novo_simbolo}, #{movimento})"

      fita[cabecote] = novo_simbolo
      estado = novo_estado

      # Movimento da cabeça
      if movimento == "d"
        cabecote += 1
      elsif movimento == "e"
        cabecote -= 1
        cabecote = 0 if cabecote < 0
      else
        # movimento inválido - termina execução
        puts "⚠️ Movimento inválido '#{movimento}'. Encerrando."
        break
      end

      # Garante símbolo branco se fora da fita
      fita[cabecote] ||= "_"

      # Mostrar fita com cabeçote destacado
      fita_str_visual = fita.map.with_index { |sim, idx| idx == cabecote ? "[#{sim}]" : sim }.join(" ")
      puts "Fita: #{fita_str_visual}"
    else
      puts "⚠️ Sem transição definida para (#{estado}, #{simbolo}). Encerrando execução."
      break
    end

    passo += 1
  end

  puts "\n🚩 Estado final: #{estado}"
  if estados_aceitacao.include?(estado) && (fita[cabecote] || "_") == "_"
    puts "✅ Aceita!"
  else
    puts "❌ Rejeita!"
  end
  puts "🧾 Fita final (codificada): " + fita.join(" ")
  puts "🔤 Fita final (traduzida): " + traduzir_fita(fita)

end

# ========= EXEMPLO DE EXECUÇÃO =========

# entrada = "fascfasccccdfasccfbsccdfbsccfbsccd#scscsccscc" # Representa a cadeia "aabbb"
# entrada = "fascfascdfasccfbsccdfbsccfbsccdscc#scscsccsccscc" # Representa a cadeia "aabbcc"
# entrada = "fascfascdfasccfbsccdfbsccfbsccd#scscscsccscc" # Representa a cadeia "aaabbb" e espera "cccccc"
# entrada = "fascfaccdfscfascdfasccfscccdfbsccc#scscscsccscc"
entrada = "fascfasdscfbsccfbscfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbsccfbs"



cod_maquina, _ = entrada.split("#")
mostrar_regras(cod_maquina)
executar_mtu(entrada)
