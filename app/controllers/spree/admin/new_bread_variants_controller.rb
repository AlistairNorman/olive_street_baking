# frozen_string_literal: true

module Spree
  module Admin
    class NewBreadVariantsController < Spree::Admin::BaseController
      def create
        product = Spree::Product.accessible_by(current_ability, :update).friendly.find(params[:product_slug])

        begin
          variants = TinyGoatBaking::CreateNewBreadVariants.call(product: product)
          flash[:success] = t('tiny_goat_baking.new_bread_variants.created', count: variants.size)
        rescue TinyGoatBaking::CreateNewBreadVariants::NoExistingPickupDate
          flash[:error] = t('tiny_goat_baking.new_bread_variants.no_existing_pickup_date')
        end

        redirect_to admin_product_stock_path(product)
      end
    end
  end
end
