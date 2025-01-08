# frozen_string_literal: true

class MaskedDataGenerator
  def self.mask_strategies
    @mask_strategies ||= {
      "uuid" => ->(_) { Faker::Internet.uuid },
      "email" => ->(_) { Faker::Internet.unique.email },
      "string" => ->(config) { Faker::Lorem.characters(number: config[:length] || 20) },
      "postcode" => ->(_) { Faker::Base.numerify("###-####", leading_zero: true) },
      "tel" => ->(_) { Faker::PhoneNumber.phone_number },
      "first_name" => ->(_) { Faker::Name.first_name },
      "last_name" => ->(_) { Faker::Name.last_name },
      "integer" => method(:generate_integer_masked_value),
      "password" => method(:generate_password_masked_value),
      "date" => method(:generate_date_masked_value),
      "enum" => method(:generate_enum_masked_value)
    }.freeze
  end

  def self.generate_integer_masked_value(config)
    min = config[:min] || 0
    max = config[:max] || 100
    Faker::Number.between(from: min, to: max)
  end

  def self.generate_password_masked_value(config)
    min_length = config[:min_length] || 10
    max_length = config[:max_length] || 20
    Faker::Internet.password(min_length: min_length, max_length: max_length)
  end

  def self.generate_date_masked_value(config)
    start_date = Date.parse(config[:start_date] || "1970-01-01")
    end_date = Date.parse(config[:end_date] || Date.today.to_s)
    Faker::Date.between(from: start_date, to: end_date)
  end

  def self.generate_enum_masked_value(config)
    values = config[:values]
    raise ArgumentError, "Enum values must be specified" if values.nil? || values.empty?

    values.sample
  end

  def self.generate_masked_value(mask_type, config = {})
    strategy = mask_strategies[mask_type]
    raise ArgumentError, "Unknown mask type: #{mask_type}" unless strategy

    strategy.call(config.transform_keys(&:to_sym))
  rescue StandardError => e
    raise ArgumentError, "Error generating masked value for #{mask_type}: #{e.message}"
  end
end
