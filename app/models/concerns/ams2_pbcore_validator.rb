class AMS2PBCoreValidator < ActiveModel::Validator

  def validate(record)
    @record = record
    @pbcore = record.pbcore
    validate_asset_type
    validate_date_type
    validate_date_format
    validate_title_presence
    validate_title_value_presence
  end

  private

  def validate_asset_type
    @pbcore.asset_types.each do |type|
      @record.errors.add(:base, "Invalid PBCore::AssetType value: #{type.value}") unless valid_asset_type_values.include?(type.value)
    end
  end

  def valid_asset_type_values
    @valid_asset_type_values ||= AMS::Cleaner::VocabMap.for_pbcore_class(PBCore::AssetType)["values"].values.uniq
  end

  def validate_date_type
    @pbcore.asset_dates.each do |date|
      @record.errors.add(:base, "Invalid PBCore::AssetDate type: #{date.type}") unless valid_asset_date_types.include?(date.type)
    end
  end

  def valid_asset_date_types
    @valid_asset_date_types ||= AMS::Cleaner::VocabMap.for_pbcore_class(PBCore::AssetDate)["types"].values.uniq
  end

  def validate_date_format
    @pbcore.asset_dates.each do |date|
      @record.errors.add(:base, "Invalid PBCore::AssetDate value: #{date.value}") if AMS::NonExactDateService.invalid?(date.value)
    end
  end

  def validate_title_presence
    @record.errors.add(:base, "No PBCore::Title found") if @pbcore.titles.empty?
  end

  def validate_title_value_presence
    @record.errors.add(:base, "Invalid PBCore::Title, value attribute is missing") if @pbcore.titles.map(&:value).map(&:present?).include?(false)
  end
end