# frozen_string_literal: true

class TinyGoatBaking::SolidusAdmin::StockItems::Index::Component < SolidusAdmin::StockItems::Index::Component
  def page_actions
    form_with url: spree.admin_product_new_bread_variants_path(Spree::Product.sole), method: :post do
      render component("ui/button").new(
        type: :submit,
        text: t("tiny_goat_baking.new_bread_variants.button"),
        icon: "add-line"
      )
    end
  end
end
