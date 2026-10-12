# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Order timestamps on the admin order page', type: :system do
  stub_authorization!

  let!(:order) do
    create(:order_with_line_items, created_at: Time.utc(2026, 1, 15, 18, 5)).tap do |order|
      order.update_column(:updated_at, Time.utc(2026, 7, 4, 2, 30))
    end
  end

  it 'shows when the order was created and last updated in Pacific time' do
    visit spree.edit_admin_order_path(order)

    expect(page).to have_content('Created:')
    expect(page).to have_content('Updated:')
    expect(page).to have_css('#order_created_at', text: 'January 15, 2026 at 10:05 AM PST')
    expect(page).to have_css('#order_updated_at', text: 'July 3, 2026 at 7:30 PM PDT')
  end
end
