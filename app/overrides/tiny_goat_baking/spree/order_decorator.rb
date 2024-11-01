module TinyGoatBaking
  module Spree
    module OrderDecorator
      def self.prepended(base)
        base.remove_checkout_step :address
        base.remove_checkout_step :delivery
      end

      ::Spree::Order.prepend self
    end
  end
end
