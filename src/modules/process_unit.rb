# @Author Daniel Almeida Luz
# @Author Guido Dutra Oliveira
# @Author Luiz Fernando Vieira
# @date Novembro, 2017
# @brief Unidade de Memória RAM
#
# Arquivo responsavel pela representação de um Processo. 
# Abrange todos os atributos que pertencem ao Processo. 
# Os atributos dos objetos dessa classe são populados 
# atraves da leitura dos arquivos files.txt e processes.txt
class ProcessUnit
  attr_reader :id, :init_time, :priority, :processor_time, :memory_blocks, :printer, :scanner, :modem, :num_code_disk
  attr_reader :instruction_index
  attr_accessor :instructions

  # Construtor responsavel pela inicializacao  
  # dos atributos do processo
  def initialize(id, init_time, priority, processor_time, memory_blocks, printer, scanner, modem, num_code_disk)
    @id = id
    @init_time = init_time
    @priority = priority
    @processor_time = processor_time
    @memory_blocks = memory_blocks
    @printer = printer
    @scanner = scanner
    @modem = modem
    @num_code_disk = num_code_disk
    @instructions = Concurrent::Array.new processor_time, :default
    @instruction_index = -1
  end

  # Metodo responsavel por verificar
  # se esse processo e um processo de usuario  
  def user_process?
    @priority > 0
  end

  # Metodo responsavel por verificar
  # se esse processo e um processo de tempo real
  def real_time_process?
    @priority.zero?
  end

  # Metodo responsavel por "executar"
  # a instrucao corrente deste processo
  def step
    @instruction_index += 1
    @instructions[@instruction_index]
  end

  def finished?
    @instructions[@instruction_index + 1].nil?
  end

  # Metodo responsavel por substituir
  # 
  def replace_default_instruction(operation, data, size)
    @instructions[@instructions.index(:default)] = parse_instruction(operation, data, size)
  end

  #   
  # 
  def attributes
    {
      id:             @id,
      init_time:      @init_time,
      priority:       @priority,
      processor_time: @processor_time,
      memory_blocks:  @memory_blocks,
      printer:        @printer,
      scanner:        @scanner,
      modem:          @modem,
      num_code_disk:  @num_code_disk,
      instructions:   @instructions
    }
  end

  private

  #   
  # 
  def parse_instruction(operation, data, size)
    case operation
    when "0"
      [:write, data, size.to_i]
    when "1"
      [:delete, data]
    end
  end

end
