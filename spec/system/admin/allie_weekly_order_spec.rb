# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe "Making Allie's weekly order when bread is stocked", type: :system do
  before { sign_in create(:admin_user) }

  let(:product) { create :product, name: "Sourdough" }
  let(:pickup_date_type) { create :option_type, name: "Pickup Date", presentation: "Pickup Date" }
  let!(:allie) { create :user, email: "allie@example.com" }
  let!(:variant) { bread_variant(pickup_date: Date.new(2026, 11, 14)) }

  before do
    create :store
    create :check_payment_method
  end

  def bread_variant(pickup_date:)
    name = pickup_date.strftime("%B %d, %Y")
    option_value = create :option_value, option_type: pickup_date_type, name: name, presentation: name
    create :variant, product: product, option_values: [option_value]
  end

  def stock_loaves(count)
    visit solidus_admin.stock_items_path
    find("a[href^='#{solidus_admin.edit_stock_item_path(variant.stock_items.first)}']", text: variant.sku).click
    fill_in "quantity_adjustment", with: count
    click_button "Save"
    expect(page).to have_css "tr", text: /#{variant.sku}\b.*\b[1-9]\d* stock movements?/m
  end

  it "orders her a loaf for that pickup date", js: true do
    stock_loaves 10

    expect(allie.orders.complete.sole.line_items.sole).to have_attributes(variant: variant, quantity: 1)
  end

  it "pays for it with her store credit when she has enough", js: true do
    create :store_credit_payment_method, auto_capture: true
    create :store_credit, amount: 20, user: allie, currency: "CAD"

    stock_loaves 10

    expect(allie.orders.complete.sole.payments.sole.payment_method).to be_a Spree::PaymentMethod::StoreCredit
    expect(allie.reload.store_credits.sole.amount_used).to eq 19.99
  end

  context "when she already has an order for that week" do
    before do
      create :completed_order_with_totals,
        line_items_attributes: [{ variant: bread_variant(pickup_date: Date.new(2026, 11, 11)), quantity: 1 }],
        user: allie
    end

    it "doesn't order her another loaf", js: true do
      expect { stock_loaves 10 }.not_to change { allie.orders.complete.count }.from(1)
    end
  end
end
