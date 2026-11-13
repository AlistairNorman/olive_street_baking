# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Pickup dates on the admin orders page', type: :system do
  before { sign_in create(:admin_user) }

  let(:pickup_date_type) { create :option_type, name: "Pickup Date" }

  def bread_variant(pickup_date:, format: "%B %d, %Y")
    option_value = create :option_value,
      option_type: pickup_date_type,
      name: pickup_date.strftime(format)
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
    visit solidus_admin.orders_path

    expect(page).to have_css "th", text: "Pickup Date"
    within("tr", text: order.number) do
      expect(page).to have_content(/Saturday, November 14th, 2026\s+Saturday, November 21st, 2026/)
    end
  end

  context 'with orders for several pickup dates' do
    let!(:december_order) {
      create :completed_order_with_totals,
        line_items_attributes: [{ variant: bread_variant(pickup_date: Date.new(2026, 12, 5), format: "%a, %b %-d, %Y"), quantity: 1 }]
    }
    let!(:january_order) {
      create :completed_order_with_totals,
        line_items_attributes: [{ variant: bread_variant(pickup_date: Date.new(2027, 1, 9)), quantity: 1 }]
    }

    def order_numbers
      all('tbody tr').map { |row| row.all('td').first.text }
    end

    it 'sorts orders by their earliest pickup date' do
      visit solidus_admin.orders_path

      click_link 'Pickup Date'
      expect(order_numbers).to eq [order.number, december_order.number, january_order.number]

      click_link 'Pickup Date'
      expect(order_numbers).to eq [january_order.number, december_order.number, order.number]
    end
  end
end
