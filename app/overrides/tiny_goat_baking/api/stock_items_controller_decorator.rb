module TinyGoatBaking
  module Api
    module StockItemsControllerDecorator
      def self.prepended(base)
        base.after_action :make_an_order_for_allie, only: [:update]
      end

      private

      def make_an_order_for_allie
        stock_item = ::Spree::StockItem.accessible_by(current_ability, :update).find(params[:id])
        ::TinyGoatBaking::MakeAllieAnOrder.call(variant: stock_item.variant)
      end

      ::Spree::Api::StockItemsController.prepend self
    end
  end
end
