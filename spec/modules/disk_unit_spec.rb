describe DiskUnit do
  let(:attributes) {
    {
      size: 10
    }
  }

  subject { DiskUnit.new(10) }
  it { is_expected.to be_a DiskUnit }
  it { is_expected.to have_attributes attributes }

  describe "#write_file" do
    it "writes correctly" do
      subject.write_file("X", 2)
      expect(subject[0..1]).to eq ["X", "X"]
      subject.write_file("Z", 2)
      expect(subject[2..3]).to eq ["Z", "Z"]

      expect(subject.written_blocks).to eq 4
    end
  end

  describe "#write" do
    it "writes correctly" do
      subject.write("X", 0, 2)
      expect(subject[0..1]).to eq ["X", "X"]
      expect(subject.written_blocks).to eq 2
    end

    context "when space required fails" do
      it "doesn't write" do
        subject.write("X", 2, 2)
        subject.write("A", 0, 3)
        expect(subject.written_blocks).to eq 2
      end
    end
  end

  describe "#delete" do
    it "deletes correctly" do
      expect {
        subject.write("X", 0, 3)
        expect(subject.written_blocks).to eq 3
        subject.delete_file("X")
        expect(subject.written_blocks).to eq 0
      }.to_not change(subject, :size)
    end
  end
end
