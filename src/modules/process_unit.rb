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
  DEVICES = [:printer, :scanner, :modem, :sata_device]
  attr_reader :id, :init_time, :priority, :processor_time, :memory_blocks, :printer, :scanner, :modem, :sata_device
  attr_reader :instruction_index
  attr_accessor :instructions

  # Construtor responsavel pela inicializacao  
  # dos atributos do processo
  def initialize(id, init_time, priority, processor_time, memory_blocks, printer, scanner, modem, sata_device)
    @id = id
    @init_time = init_time
    @priority = priority
    @processor_time = processor_time
    @memory_blocks = memory_blocks
    @printer = printer > 0
    @scanner = scanner > 0
    @modem = modem > 0
    @sata_device = sata_device > 0
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

  def devices
    attributes.select {|key, value| DEVICES.include?(key) && value }.keys
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
      sata_device:    @sata_device,
      instructions:   @instructions
    }
  end

  def print
    attributes.to_s
  end

  private

  #   
  # 
  def parse_instruction(operation, data, size)
    case operation
    when "0"
      [:write_file, data, size.to_i]
    when "1"
      [:delete_file, data]
    end
  end

end
