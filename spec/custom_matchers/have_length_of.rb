RSpec::Matchers.define :have_length_of do |expected|
  match do |actual|
    actual.length == expected
  end
end
