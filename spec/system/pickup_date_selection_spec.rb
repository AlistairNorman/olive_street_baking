# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Choosing a pickup date', type: :system do
  let!(:store) { create :store }
  let(:product) { create :product, name: "Sourdough" }
  let(:pickup_date_type) { create :option_type, name: "Pickup Date", presentation: "Pickup Date" }
  let(:next_week) { 1.week.from_now.to_date.strftime("%B %d, %Y") }
  let(:week_after) { 2.weeks.from_now.to_date.strftime("%B %d, %Y") }

  def create_pickup_date(pickup_date, count_on_hand:)
    option_value = create :option_value, option_type: pickup_date_type, name: pickup_date, presentation: pickup_date
    variant = create :variant, product: product, option_values: [option_value]
    variant.stock_items.each { |stock_item| stock_item.set_count_on_hand(count_on_hand) }
    variant
  end

  before do
    product.option_types << pickup_date_type
    create_pickup_date next_week, count_on_hand: 3
    create_pickup_date week_after, count_on_hand: 7
  end

  it 'adds the loaf for the date picked from the dropdown to the cart', js: true do
    visit product_path(product)

    select week_after, from: "Pickup Date"
    click_button "add-to-cart-button"

    expect(page).to have_content "Shopping Cart"
    expect(page).to have_content week_after
    expect(page).not_to have_content next_week
  end

  it 'only offers as many loaves as there are for the chosen date', js: true do
    visit product_path(product)
    expect(page).to have_select "quantity", options: %w[1 2 3]

    select "3", from: "quantity"
    select week_after, from: "Pickup Date"
    expect(page).to have_select "quantity", options: %w[1 2 3 4 5 6 7], selected: "3"
  end

  it 'shows sold out upcoming bakes without letting them be picked', js: true do
    tomorrow = 1.day.from_now.to_date.strftime("%B %d, %Y")
    sold_out = create_pickup_date tomorrow, count_on_hand: 0
    last_week = create_pickup_date 1.week.ago.to_date.strftime("%B %d, %Y"), count_on_hand: 0
    [sold_out, last_week].each { |variant| create :line_item, variant: variant, order: create(:completed_order_with_totals) }
    create_pickup_date 3.weeks.from_now.to_date.strftime("%B %d, %Y"), count_on_hand: 0

    visit product_path(product)

    expect(page).to have_select "Pickup Date",
      options: ["#{tomorrow} (sold out)", next_week, week_after],
      disabled_options: ["#{tomorrow} (sold out)"],
      selected: next_week

    within "#upcoming-pickup-dates" do
      expect(page.all("li").map(&:text)).to eq ["#{tomorrow} (sold out)", next_week, week_after]
    end
  end

  it 'lists sold out upcoming bakes without a pickup date dropdown when none are left', js: true do
    product.variants.each { |variant|
      variant.stock_items.each { |stock_item| stock_item.set_count_on_hand(0) }
      create :line_item, variant: variant, order: create(:completed_order_with_totals)
    }
    product.master.stock_items.update_all(count_on_hand: 0, backorderable: false)

    visit product_path(product)

    within "#upcoming-pickup-dates" do
      expect(page.all("li").map(&:text)).to eq ["#{next_week} (sold out)", "#{week_after} (sold out)"]
    end
    expect(page).not_to have_select "Pickup Date"
    expect(page).not_to have_button "add-to-cart-button"
    expect(page).not_to have_content "Out of Stock"
  end
end
