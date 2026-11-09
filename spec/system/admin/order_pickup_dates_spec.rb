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
end
