# 🧠 Explicação do Código da Máquina de Turing Universal (MTU)

Este código implementa uma **Máquina de Turing Universal (MTU)** capaz de simular qualquer outra máquina codificada em uma string. A entrada tem o seguinte formato:

```
<codificação_da_máquina>#<cadeia_codificada>
```

Exemplo:
```
fascfasccdfasccfbsccdfbsccfbsccd#scscscc
```

---

## 🔧 Funções Principais

### `extrair_bloco(str, idx, prefixo)`
- Lê um "bloco" da codificação, iniciando por um prefixo (`f` para estados, `s` para símbolos).
- Exemplo: `"fasc"` representa um estado.

### `parse_maquina(cod)`
- Interpreta a codificação da máquina.
- Retorna:
  - Dicionário de transições
  - Estado inicial (o primeiro)
  - Estados de aceitação (aqueles que começam com `fb`)

### `traduzir_fita(fita)`
- Converte a fita codificada em símbolos legíveis:
  - `sc` → `'a'`
  - `scc` → `'b'`
  - `_` → espaço branco (`␣`)

### `mostrar_regras(cod)`
- Mostra todas as transições da máquina interpretadas do código.

### `executar_mtu(entrada)`
- Executa a simulação da máquina:
  - Interpreta transições e fita
  - Simula passo a passo com movimentos do cabeçote
  - Mostra fita, estado e aceita/rejeita

---

## 🧪 Exemplo

**Entrada**:
```
fascfasccdfasccfbsccdfbsccfbsccd#scscscc
```

**Explicação**:
- Máquina que aceita cadeias da forma `a^*b^+`
- A fita `scscsccscc` representa a string `aabbb`

---

## ✅ Resultado

Ao executar, a MTU mostra:

- 📜 Transições aplicadas
- 🤖 Estado atual e símbolo lido
- 🧾 Fita final (codificada e traduzida)
- ✅ Aceita ou ❌ Rejeita

---
