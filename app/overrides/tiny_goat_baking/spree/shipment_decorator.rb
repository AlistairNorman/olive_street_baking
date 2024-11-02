module TinyGoatBaking
  module Spree
    module ShipmentDecorator
      private

      def can_get_rates?
        true
      end

      ::Spree::Shipment.prepend self
    end
  end
end
