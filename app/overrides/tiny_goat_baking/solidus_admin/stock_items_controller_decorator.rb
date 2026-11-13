module TinyGoatBaking
  module SolidusAdmin
    module StockItemsControllerDecorator
      def self.prepended(base)
        base.after_action :make_an_order_for_allie, only: [:update], if: -> { response.redirect? }
      end

      private

      def make_an_order_for_allie
        ::TinyGoatBaking::MakeAllieAnOrder.call(variant: @stock_item.variant)
      end

      ::SolidusAdmin::StockItemsController.prepend self
    end
  end
end
