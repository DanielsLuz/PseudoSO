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
    address = initial_address(process)
    return false if address.nil?
    @user_memory[address, process.memory_blocks] = Concurrent::Array.new(process.memory_blocks, process.id)
    address
  end

  # Método 
  def written_blocks
    (@real_time_memory + @user_memory).reject(&:nil?).count
  end

  private

  # Método 
  def initial_address(process)
    initial_address = nil
    @user_memory.each_with_index {|elem, index|
      next unless elem.nil?
      return index if @user_memory[index, process.memory_blocks].all?(&:nil?)
    }
    initial_address
  end
end
