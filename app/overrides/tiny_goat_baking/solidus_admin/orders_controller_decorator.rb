module TinyGoatBaking
  module SolidusAdmin
    module OrdersControllerDecorator
      private

      def apply_scopes_to(relation, param:)
        relation = super.includes(line_items: { variant: { option_values: :option_type } })
        params.dig(param, :s).present? ? relation.reorder(nil) : relation
      end

      ::SolidusAdmin::OrdersController.prepend self
    end
  end
end
