module TinyGoatBaking
  module Spree
    module Api
      module StockItemsControllerDecorator
        def self.prepended(base)
          base.before_action :make_an_order_for_allie, only: [:update]
        end

        private

        def make_an_order_for_allie
          stock_item = ::Spree::StockItem.accessible_by(current_ability, :update).find(params[:id])
          allie = ::Spree::User.find_by(email: ENV['ALLIE_EMAIL'])

          return unless allie
          return if ::Spree::Order.joins(:line_items).exists?(
            user: allie,
            state: 'complete',
            spree_line_items: { variant_id: stock_item.variant_id }
          )

          order = ::Spree::Order.create(
            user: allie,
            store: ::Spree::Store.default,
            line_items: [::Spree::LineItem.new(variant: stock_item.variant, quantity: 1)]
          )
          payment_method = ::Spree::PaymentMethod
            .active.find_by(type: "Spree::PaymentMethod::Check")
          order.payments.create(
            amount: 9,
            payment_method: payment_method
          )
          order.recalculate


          while !order.can_complete?
            order.next
          end

          order.complete!
        end

        ::Spree::Api::StockItemsController.prepend self
      end
    end
  end
end
