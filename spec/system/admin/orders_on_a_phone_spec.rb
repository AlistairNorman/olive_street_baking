# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'The admin orders page on a phone', type: :system, js: true do
  let!(:order) { create :completed_order_with_totals }

  before do
    sign_in create(:admin_user)
    page.driver.browser.execute_cdp("Emulation.setDeviceMetricsOverride", width: 390, height: 844, deviceScaleFactor: 1, mobile: true)
  end

  after { page.driver.browser.execute_cdp("Emulation.clearDeviceMetricsOverride") }

  it 'shows only the columns that fit, without scrolling sideways' do
    visit solidus_admin.orders_path

    expect(page.all("thead th", visible: true).map(&:text)).to eq ["Order", "Pickup Date", "Customer", "Capture"]
    expect(page).to have_content order.number
    expect(page.evaluate_script("document.documentElement.scrollWidth")).to eq 390
  end

  it 'opens the admin menu from the Menu button' do
    visit solidus_admin.orders_path
    expect(page).not_to have_link "Cookies"

    find("label", text: "Menu").click

    expect(page).to have_link "Cookies"
  end
end
