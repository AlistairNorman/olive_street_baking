# frozen_string_literal: true

module TinyGoatBaking
  class MakeAllieAnOrder
    def self.call(variant:)
      new(variant: variant).call
    end

    def initialize(variant:)
      @variant = variant
    end

    def call
      allie = ::Spree::User.find_by(email: ENV['ALLIE_EMAIL'])
      pickup_date = variant.pickup_date

      return unless allie && pickup_date
      return if allie_has_order_in_week?(allie, pickup_date)

      order = ::Spree::Order.create(
        user: allie,
        store: ::Spree::Store.default,
        line_items: [::Spree::LineItem.new(variant: variant, quantity: 1)]
      )
      store_credit = allie.store_credits.find { |credit|
        credit.amount_remaining >= variant.display_price.to_d
      }
      if store_credit
        payment_method = ::Spree::PaymentMethod.active.find_by(type: "Spree::PaymentMethod::StoreCredit")
        payment = order.payments.create(
          amount: variant.display_price.to_d,
          payment_method: payment_method,
          source: store_credit
        )
        payment.process!
      else
        payment_method = ::Spree::PaymentMethod.active.find_by(type: "Spree::PaymentMethod::Check")
        order.payments.create(
          amount: variant.display_price.to_d,
          payment_method: payment_method
        )
      end

      order.recalculate

      while !order.can_complete?
        order.next
      end

      order.complete!
    end

    private

    attr_reader :variant

    def allie_has_order_in_week?(allie, pickup_date)
      week = pickup_date.all_week

      allie.orders.complete.includes(line_items: { variant: { option_values: :option_type } }).any? { |order|
        order.line_items.any? { |line_item| week.cover?(line_item.variant.pickup_date) }
      }
    end
  end
end
