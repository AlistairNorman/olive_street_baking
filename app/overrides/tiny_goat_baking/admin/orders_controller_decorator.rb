module TinyGoatBaking
  module Admin
    module OrdersControllerDecorator
      def index
        super
        @orders = @orders.includes(line_items: { variant: { option_values: :option_type } })
      end

      private

      def require_ship_address
      end

      ::Spree::Admin::OrdersController.prepend self
    end
  end
end
