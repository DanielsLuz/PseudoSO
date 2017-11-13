module Resources
  def self.file(filename)
    File.join(PseudoSO::ROOT_PATH, "resources", filename)
  end
end
