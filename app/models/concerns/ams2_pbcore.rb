class AMS2PBcore
  # This class is used to wrap the PBCore::DescriptionDocument from
  # the PBCore gem: https://github.com/WGBH-MLA/pbcore.
  # It allows us to use ActiveModel::Validations and a custom validator.
  include ActiveModel::Validations
  validates_with AMS2PBCoreValidator

  attr_reader :pbcore

  def initialize(pbcore:)
    raise 'AMS2PBcore must be initialized with a PBCore::DescriptionDocument' unless pbcore.class == PBCore::DescriptionDocument
    @pbcore = pbcore
  end

end