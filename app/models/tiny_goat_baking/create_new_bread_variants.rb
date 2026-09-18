# frozen_string_literal: true

module TinyGoatBaking
  class CreateNewBreadVariants
    PICKUP_DATE_OPTION_TYPE_NAME = 'Pickup Date'
    PICKUP_DATE_FORMAT = '%B %d, %Y'
    VARIANTS_CREATED = 10

    class NoExistingPickupDate < StandardError; end

    def self.call(product:)
      new(product: product).call
    end

    def initialize(product:)
      @product = product
    end

    def call
      pickup_date = last_pickup_date

      ::ApplicationRecord.transaction do
        Array.new(VARIANTS_CREATED) do
          pickup_date += 7.days
          create_variant(pickup_date)
        end
      end
    end

    private

    attr_reader :product

    def pickup_date_option_type
      @pickup_date_option_type ||= ::Spree::OptionType.find_by!(name: PICKUP_DATE_OPTION_TYPE_NAME)
    end

    def last_pickup_date
      latest = pickup_date_option_type.option_values.max_by { |option_value| option_value.name.to_date }
      raise NoExistingPickupDate if latest.nil?

      latest.name.to_date
    end

    def create_variant(pickup_date)
      option_value = pickup_date_option_type.option_values.create!(
        name: pickup_date.strftime(PICKUP_DATE_FORMAT),
        presentation: pickup_date.strftime(PICKUP_DATE_FORMAT)
      )

      ::Spree::Variant.create!(product: product, option_values: [option_value])
    end
  end
end
