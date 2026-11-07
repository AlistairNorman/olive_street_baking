module TinyGoatBaking
  module Spree
    module VariantDecorator
      def pickup_date
        option_values.find { |option_value|
          option_value.option_type.name == ::TinyGoatBaking::CreateNewBreadVariants::PICKUP_DATE_OPTION_TYPE_NAME
        }&.name&.to_date
      end

      ::Spree::Variant.prepend self
    end
  end
end
