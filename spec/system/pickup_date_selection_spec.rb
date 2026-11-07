# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Choosing a pickup date', type: :system do
  let!(:store) { create :store }
  let(:product) { create :product, name: "Sourdough" }
  let(:pickup_date_type) { create :option_type, name: "Pickup Date", presentation: "Pickup Date" }

  before do
    product.option_types << pickup_date_type
    ["November 14, 2026", "November 21, 2026"].each do |pickup_date|
      option_value = create :option_value, option_type: pickup_date_type, name: pickup_date, presentation: pickup_date
      variant = create :variant, product: product, option_values: [option_value]
      variant.stock_items.each { |stock_item| stock_item.set_count_on_hand(5) }
    end
  end

  it 'adds the loaf for the date picked from the dropdown to the cart', js: true do
    visit product_path(product)

    select "November 21, 2026", from: "Pickup Date"
    click_button "add-to-cart-button"

    expect(page).to have_content "Shopping Cart"
    expect(page).to have_content "November 21, 2026"
    expect(page).not_to have_content "November 14, 2026"
  end
end
