module TinyGoatBaking
  module Api
    module StockItemsControllerDecorator
      def self.prepended(base)
        base.after_action :make_an_order_for_allie, only: [:update]
      end

      private

      def make_an_order_for_allie
        stock_item = ::Spree::StockItem.accessible_by(current_ability, :update).find(params[:id])
        allie = ::Spree::User.find_by(email: ENV['ALLIE_EMAIL'])

        pickup_date = pickup_date_of(stock_item.variant)

        return unless allie && pickup_date
        return if allie_has_order_in_week?(allie, pickup_date)

        order = ::Spree::Order.create(
          user: allie,
          store: ::Spree::Store.default,
          line_items: [::Spree::LineItem.new(variant: stock_item.variant, quantity: 1)]
        )
        store_credit = allie.store_credits.find { |credit|
          credit.amount_remaining >= stock_item.variant.display_price.to_d
        }
        if store_credit
          payment_method = ::Spree::PaymentMethod.active.find_by(type: "Spree::PaymentMethod::StoreCredit")
          payment = order.payments.create(
            amount: stock_item.variant.display_price.to_d,
            payment_method: payment_method,
            source: store_credit
          )
          payment.process!
        else
          payment_method = ::Spree::PaymentMethod.active.find_by(type: "Spree::PaymentMethod::Check")
          order.payments.create(
            amount: stock_item.variant.display_price.to_d,
            payment_method: payment_method
          )
        end

        order.recalculate

        while !order.can_complete?
          order.next
        end

        order.complete!
      end

      def allie_has_order_in_week?(allie, pickup_date)
        week = pickup_date.all_week

        allie.orders.complete.includes(line_items: { variant: { option_values: :option_type } }).any? { |order|
          order.line_items.any? { |line_item| week.cover?(pickup_date_of(line_item.variant)) }
        }
      end

      def pickup_date_of(variant)
        variant.option_values.find { |option_value|
          option_value.option_type.name == ::TinyGoatBaking::CreateNewBreadVariants::PICKUP_DATE_OPTION_TYPE_NAME
        }&.name&.to_date
      end

      ::Spree::Api::StockItemsController.prepend self
    end
  end
end
