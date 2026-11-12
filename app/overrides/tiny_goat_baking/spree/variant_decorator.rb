module TinyGoatBaking
  module Spree
    module VariantDecorator
      def pickup_date_option_value
        option_values.find { |option_value|
          option_value.option_type.name == ::TinyGoatBaking::CreateNewBreadVariants::PICKUP_DATE_OPTION_TYPE_NAME
        }
      end

      def pickup_date
        pickup_date_option_value&.name&.to_date
      end

      def upcoming_bake?
        return false if pickup_date.nil? || pickup_date.past?

        in_stock? || orders.complete.exists?
      end

      ::Spree::Variant.prepend self
    end
  end
end
