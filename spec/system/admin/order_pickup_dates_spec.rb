# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Pickup dates on the admin orders page', type: :system do
  stub_authorization!

  let(:pickup_date_type) { create :option_type, name: "Pickup Date" }

  def bread_variant(pickup_date:)
    option_value = create :option_value,
      option_type: pickup_date_type,
      name: pickup_date.strftime("%B %d, %Y")
    create :variant, option_values: [option_value]
  end

  let!(:order) {
    create :completed_order_with_totals,
      line_items_attributes: [
        { variant: bread_variant(pickup_date: Date.new(2026, 11, 21)), quantity: 1 },
        { variant: bread_variant(pickup_date: Date.new(2026, 11, 14)), quantity: 1 }
      ]
  }

  it 'shows every pickup date in the order' do
    visit spree.admin_orders_path

    within("#listing_orders") do
      expect(page).to have_css "th", text: "Pickup Date"
      within("tr", text: order.number) do
        expect(page).to have_content(/Sat, Nov 14, 2026\s+Sat, Nov 21, 2026/)
      end
    end
  end

  context 'with orders for several pickup dates' do
    let!(:december_order) {
      create :completed_order_with_totals,
        line_items_attributes: [{ variant: bread_variant(pickup_date: Date.new(2026, 12, 5)), quantity: 1 }]
    }
    let!(:january_order) {
      create :completed_order_with_totals,
        line_items_attributes: [{ variant: bread_variant(pickup_date: Date.new(2027, 1, 9)), quantity: 1 }]
    }

    def order_numbers
      all('#listing_orders tbody tr').map { |row| row.find('td', text: /\AR\d+\z/).text }
    end

    it 'sorts orders by their earliest pickup date' do
      visit spree.admin_orders_path

      click_link 'Pickup Date'
      expect(order_numbers).to eq [order.number, december_order.number, january_order.number]

      click_link 'Pickup Date'
      expect(order_numbers).to eq [january_order.number, december_order.number, order.number]
    end
  end
end
