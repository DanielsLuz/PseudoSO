# @Author Daniel Almeida Luz
# @Author Guido Dutra Oliveira
# @Author Luiz Fernando Vieira
# @date Novembro, 2017
# @brief Unidade de Memória RAM
#
# Arquivo responsável pela representação e manipulação da 
# memória RAM utilizada pelo SO simulado. Essa memória RAM
# é dividida em duas partes. A primeira é composta por 64
# blocos para processos de tempo real e 960 para processos
# de usuário. Os métodos dessa classe envolvem operações 
# de escrita e deleção de "processos" na memória simulada.

class MemoryUnit

  # Construtor responsável pela inicialização dos 
  # arrays que armazenam os processos de tempo real 
  # e os processos de usuário
  def initialize(real_time_memory=Concurrent::Array.new(64), user_memory=Concurrent::Array.new(960))
    @real_time_memory = real_time_memory
    @user_memory = user_memory
  end

  # Método responsável pela soma dos tamanhos
  # do array de processos de tempo real com
  # o array de processos do usuário
  def size
    @real_time_memory.size + @user_memory.size
  end

  # Método 
  def alocate(process)
    memory = process.real_time_process? ? @real_time_memory : @user_memory
    address = initial_address(memory, process)
    return false if address.nil?
    write(memory, address, process)
    address
  end

  # Método 
  def written_blocks
    (@real_time_memory + @user_memory).reject(&:nil?).count
  end

  private

  def write(memory, address, process)
    memory[address, process.memory_blocks] = Concurrent::Array.new(process.memory_blocks, process.id)
  end

  def initial_address(memory, process)
    initial_address = nil
    memory.each_with_index {|elem, index|
      next unless elem.nil?
      memory_slot = memory[index, process.memory_blocks]
      break if memory_slot.size < process.memory_blocks
      return index if memory_slot.all?(&:nil?)
    }
    initial_address
  end
end
