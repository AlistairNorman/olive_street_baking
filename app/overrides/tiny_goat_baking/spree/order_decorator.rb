module TinyGoatBaking
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.remove_checkout_step :address
        base.remove_checkout_step :delivery
        base.remove_checkout_step :confirm

        base.state_machine.before_transition to: :complete, do: :create_proposed_shipments
      end

      private

      # Solidus hangs `add_store_credit_payments` off the transition into
      # :confirm, so removing the confirm step above means store credit
      # payments never get built and completing the order fails with "No
      # payment found".
      #
      # We can't just re-register it as a `before_transition to: :complete`
      # callback: state machine callbacks run in the order they're defined, and
      # anything we add from here lands *after* core's
      # `process_payments_before_complete`, which is what needs the payments to
      # already exist. Hooking the method itself keeps the ordering correct.
      def process_payments_before_complete
        add_store_credit_payments
        super
      end

      ::Spree::Order.prepend self
    end
  end
end
