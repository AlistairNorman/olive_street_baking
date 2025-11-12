module TinyGoatBaking
  module Admin
    module OrdersControllerDecorator
      private

      def require_ship_address
      end

      ::Spree::Admin::OrdersController.prepend self
    end
  end
end
