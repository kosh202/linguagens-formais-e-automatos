# Máquina de Turing Universal (MTU) em Ruby
# Esta MTU lê a codificação de uma máquina M e uma entrada w,
# e simula o comportamento de M sobre w.

class MTU
  attr_accessor :transitions, :tape, :head, :state

  def initialize(input)
    machine_code, input_code = input.split('#')
    @transitions = parse_transitions(machine_code)
    @tape = input_code.scan(/s[c]+|_/)
    @head = 0
    @state = 'fa'
  end

  def parse_transitions(code)
    transitions = {}
    rules = code.scan(/f[a|b]+s[c]+f[a|b]+s[c]+[de]/)

    rules.each do |rule|
      parts = rule.scan(/f[a|b]+|s[c]+|[de]/)
      current_state, read_symbol, next_state, write_symbol, direction = parts
      transitions[[current_state, read_symbol]] = [next_state, write_symbol, direction]
    end

    transitions
  end

  def step
    current_symbol = tape[head] || '_'
    action = transitions[[state, current_symbol]]

    if action.nil?
      return false # sem transição, para
    end

    next_state, write_symbol, direction = action
    tape[head] = write_symbol
    self.state = next_state

    if direction == 'd'
      self.head += 1
    elsif direction == 'e'
      self.head -= 1
      self.head = 0 if self.head < 0
    end

    true
  end

  def run
    while step
      # pode imprimir para debug se quiser
    end
    state.start_with?('fb')
  end
end

# Exemplo de uso:
entrada = 'fascfascdfasccfbsccdfbsccfbsccd#scscsccscc'
mtu = MTU.new(entrada)
if mtu.run
  puts 'ACEITA'
else
  puts 'REJEITA'
end
