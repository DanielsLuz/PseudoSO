# @Author Daniel Almeida Luz
# @Author Guido Dutra Oliveira
# @Author Luiz Fernando Vieira
# @date Novembro, 2017
# @brief Unidade de Memoria RAM
#
# Arquivo responsavel pela representacao e manipulacao da 
# memoria RAM utilizada pelo SO simulado. Essa memoria RAM
# e dividida em duas partes. A primeira e composta por 64
# blocos para processos de tempo real e 960 para processos
# de usuario. Os metodos dessa classe envolvem operacoes 
# de escrita e delecao de "processos" na memoria simulada.
class MemoryUnit
  class ProcessTooBigError < StandardError; end

  # Construtor responsavel pela inicializacao dos 
  # arrays que armazenam os processos de tempo real 
  # e os processos de usuario
  def initialize(real_time_memory=Concurrent::Array.new(64), user_memory=Concurrent::Array.new(960))
    @real_time_memory = real_time_memory
    @user_memory = user_memory
    @logger = OSLog.instance
  end

  # Metodo responsavel pela soma dos tamanhos
  # do array de processos de tempo real com
  # o array de processos do usuario
  def size
    @real_time_memory.size + @user_memory.size
  end

  # Metodo responsavel por inserir o processo
  # no primeiro espaço de memoria livre 
  def alocate(process)
    return alocated(process) if alocated(process)
    memory = process.real_time_process? ? @real_time_memory : @user_memory
    address = initial_address(memory, process)
    return nil if address.nil?
    write(memory, address, process)
    address
  end

  def dealocate(process)
    return true unless alocated(process)
    @logger.info(self, "Dealocating memory for process ##{process.id}...")
    memory = process.real_time_process? ? @real_time_memory : @user_memory
    first_index, size = memory.index(process.id), process.memory_blocks
    memory[first_index, size] = Concurrent::Array.new(size, nil)
  end

  def alocated(process)
    (@user_memory + @real_time_memory).index(process.id)
  end

  # Metodo responsavel por contar a quantidade
  # de blocos preenchidos na memoria RAM
  def written_blocks
    (@real_time_memory + @user_memory).reject(&:nil?).count
  end

  def test(process)
    memory = process.real_time_process? ? @real_time_memory : @user_memory
    return true if process.memory_blocks <= memory.size
    raise ProcessTooBigError, "Process is bigger (#{process.memory_blocks} blocks) than total memory"
  end

  private

  # Metodo responsavel pela escritao de
  # um processo na posicao de memoria
  # passada como parametro
  def write(memory, address, process)
    memory[address, process.memory_blocks] = Concurrent::Array.new(process.memory_blocks, process.id)
  end

  # Metodo responsavel por retornar o 
  # indice do primeiro bloco capaz
  # de alocar o processo
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
