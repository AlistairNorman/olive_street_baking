# frozen_string_literal: true

module Spree
  module Admin
    class OrderPaymentCapturesController < Spree::Admin::BaseController
      def create
        order = Spree::Order.find_by!(number: params[:order_id])

        begin
          order.capturable_payments.each do |payment|
            authorize! :capture, payment
            payment.capture!
          end
          flash[:success] = t('tiny_goat_baking.order_payment_captures.captured', number: order.number)
        rescue Spree::Core::GatewayError => error
          flash[:error] = t('tiny_goat_baking.order_payment_captures.failed', number: order.number, message: error.message)
        end

        redirect_back_or_to admin_orders_path
      end

      private

      def model_class
        Spree::Payment
      end
    end
  end
end
