module FormHelper
  def get_random_string(length=5)
    source=("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a + ["_","-","."]
    key=""
    length.times{ key += source[rand(source.size)].to_s }
    return key
  end
end

RSpec.configure { |c| c.include FormHelper }
