module TinyGoatBaking
  module Spree
    module Api
      module OrdersControllerDecorator
        private

        def require_ship_address
        end

        ::Spree::Admin::OrdersController.prepend self
      end
    end
  end
end
