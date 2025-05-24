require_relative "mtu"

# Exemplo de MT para linguagem a*b+ (qualquer número de a's, seguido de ao menos 1 b)
# Estados:
# - fa: inicial
# - fb: aceitação
#
# Regras:
# (fa, sc)  → (fa, sc, d)
# (fa, scc) → (fb, scc, d)
# (fb, scc) → (fb, scc, d)

entrada = "fascd fascd fasccd fbsccd fbsccd#scscsccsccscc"
m = MTU.new(entrada)
m.run
