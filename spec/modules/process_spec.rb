require 'modules/process_unit.rb'

describe ProcessUnit do
  subject {
    ProcessUnit.new(init_time: 2,
                    priority: 0,
                    processor_time: 7,
                    memory_blocks: 64,
                    printer: 1,
                    scanner: 0,
                    modem: 0,
                    num_code_disk: 0)
  }

  it { is_expected.to be_a ProcessUnit }

  it "initializes values" do
    expect(subject.init_time).to eq 2
    expect(subject.priority).to eq 0
    expect(subject.processor_time).to eq 7
    expect(subject.memory_blocks).to eq 64
    expect(subject.printer).to eq 1
    expect(subject.scanner).to eq 0
    expect(subject.modem).to eq 0
    expect(subject.num_code_disk).to eq 0
  end
end
