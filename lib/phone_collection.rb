# frozen_string_literal: true

# Class to store multiple phone numbers
# Each number is associated with a type (mobile, home, work)
class PhoneCollection
  TYPES = %w[mobile home work].reduce({}) do |hash, type|
    hash.merge!(type => "#{type}_phone")
  end.freeze

  def self.attributes
    TYPES.values
  end

  def self.types_as_options
    TYPES.each_key.map { |type| type_option(type) }
  end

  def self.type_option(type)
    [I18n.t("phone_collection.#{type}_phone"), type]
  end

  def initialize(address)
    @address = address
  end

  def default_number
    @address.send(default[:attribute])
  end

  def default_type
    default[:type]
  end

private

  def default
    TYPES.each do |type, attribute|
      number = @address.public_send(attribute)
      return { type: type, attribute: attribute } if number.present?
    end

    # fallback to first type if all blank
    type, attribute = TYPES.first
    { type: type, attribute: attribute }
  end
end
