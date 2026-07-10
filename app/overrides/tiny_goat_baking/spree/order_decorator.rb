module TinyGoatBaking
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.remove_checkout_step :address
        base.remove_checkout_step :delivery
        base.remove_checkout_step :confirm

        base.state_machine.before_transition to: :complete, do: :create_proposed_shipments
      end

      ::Spree::Order.prepend self
    end
  end
end
