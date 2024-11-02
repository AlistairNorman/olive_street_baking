module TinyGoatBaking
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.remove_checkout_step :address
        base.remove_checkout_step :delivery

        base.state_machine.before_transition to: :confirm, do: :create_proposed_shipments
      end

      ::Spree::Order.prepend self
    end
  end
end
