module TinyGoatBaking
  module Spree
    module OptionValueDecorator
      def self.prepended(base)
        base.before_validation :set_pickup_date_from_name, if: :pickup_date_option_value?
        base.validates :pickup_date, presence: { message: :unreadable_pickup_date }, if: :pickup_date_option_value?
      end

      def pickup_date_option_value?
        option_type&.name == ::TinyGoatBaking::CreateNewBreadVariants::PICKUP_DATE_OPTION_TYPE_NAME
      end

      private

      def set_pickup_date_from_name
        self.pickup_date = ::TinyGoatBaking::PickupDate.parse(name) if name_changed? || pickup_date.nil?
      end

      ::Spree::OptionValue.prepend self
    end
  end
end
