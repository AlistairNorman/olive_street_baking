module TinyGoatBaking
  module Admin
    module NewBreadVariantsButton
      ::Deface::Override.new(
        virtual_path: 'spree/admin/stock_items/index',
        name: 'new_bread_variants_button',
        insert_after: 'erb[loud]:contains("product_tabs")',
        partial: 'spree/admin/stock_items/new_bread_variants_button'
      )
    end
  end
end
