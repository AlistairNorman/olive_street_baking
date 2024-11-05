# frozen_string_literal: true

class CartLineItemsController < StoreController
  helper 'spree/products', 'orders'

  respond_to :html

  before_action :store_guest_token

  # Adds a new item to the order (creating a new order if none already exists)
  def create
    @order = current_order(create_order_if_necessary: true)
    authorize! :update, @order, cookies.signed[:guest_token]

    variant  = Spree::Variant.find(params[:variant_id])
    quantity = params[:quantity].present? ? params[:quantity].to_i : 1
    total_quantity = @order.line_items.where(variant: variant).sum(&:quantity) + quantity

    # 2,147,483,647 is crazy. See issue https://github.com/spree/spree/issues/2695.
    if !quantity.between?(1, 2_147_483_647)
      @order.errors.add(:base, t('spree.please_enter_reasonable_quantity'))
    elsif !variant.can_supply?(total_quantity)
      @order.errors.add(:base, "Insufficient stock")
    else
      begin
        @line_item = @order.contents.add(variant, quantity)
      rescue ActiveRecord::RecordInvalid => error
        @order.errors.add(:base, error.record.errors.full_messages.join(", "))
      end
    end

    respond_to do |format|
      format.html do
        if @order.errors.any?
          flash[:error] = @order.errors.full_messages.join(", ")
          redirect_back(fallback_location: product_path(variant.product))
          return
        else
          redirect_to cart_path
        end
      end
    end
  end

  private

  def store_guest_token
    cookies.permanent.signed[:guest_token] = params[:token] if params[:token]
  end
end
