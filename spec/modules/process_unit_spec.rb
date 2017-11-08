describe ProcessUnit do
  let(:attributes) {
    {
      init_time:      2,
      priority:       0,
      processor_time: 7,
      memory_blocks:  64,
      printer:        1,
      scanner:        0,
      modem:          0,
      num_code_disk:  0
    }
  }

  subject { ProcessUnit.new(2, 0, 7, 64, 1, 0, 0, 0) }

  it { is_expected.to be_a ProcessUnit }
  it { is_expected.to have_attributes attributes }
end
