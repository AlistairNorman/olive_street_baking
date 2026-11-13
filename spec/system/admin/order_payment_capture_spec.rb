# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Capturing payments from the admin orders page', type: :system do
  before { sign_in create(:admin_user) }

  let!(:order) { create :completed_order_with_pending_payment, payment_state: 'balance_due' }

  it 'captures the pending payment once confirmed and returns to the orders page', js: true do
    visit solidus_admin.orders_path

    within('tr', text: order.number) { click_button 'Capture' }
    expect(page).to have_css "#confirm", text: "Capture #{order.display_total} for #{order.number}?"
    find('#confirm-accept').click

    expect(page).to have_content "Captured payment for #{order.number}."
    expect(page).to have_current_path solidus_admin.orders_path
    expect(order.payments.reload.map(&:state)).to eq ['completed']
    expect(order.reload.payment_state).to eq 'paid'
    within('tr', text: order.number) { expect(page).to have_no_button 'Capture' }
  end

  it 'leaves the payment alone when the confirmation is dismissed', js: true do
    visit solidus_admin.orders_path

    within('tr', text: order.number) { click_button 'Capture' }
    within('#confirm') { click_button 'Cancel' }

    expect(page).to have_no_css "#confirm dialog[open]"
    expect(page).to have_button 'Capture'
    expect(order.payments.reload.map(&:state)).to eq ['pending']
  end

  context 'when the order was paid by check' do
    let!(:order) { create :completed_order_with_totals, payment_state: 'balance_due' }

    before do
      create :payment, order: order, amount: order.total, state: 'checkout', payment_method: create(:check_payment_method)
    end

    it 'captures the check payment', js: true do
      visit solidus_admin.orders_path

      within('tr', text: order.number) { click_button 'Capture' }
      find('#confirm-accept').click

      expect(page).to have_content "Captured payment for #{order.number}."
      expect(order.payments.reload.map(&:state)).to eq ['completed']
      expect(order.reload.payment_state).to eq 'paid'
    end
  end

  context 'when the order is paid' do
    let!(:order) { create :order_ready_to_ship }

    it 'has no capture button' do
      visit solidus_admin.orders_path

      within('tr', text: order.number) { expect(page).to have_no_button 'Capture' }
    end
  end

  context 'when the order has no payment that can be captured' do
    let!(:order) { create :completed_order_with_totals, payment_state: 'balance_due' }

    it 'has no capture button' do
      visit solidus_admin.orders_path

      within('tr', text: order.number) { expect(page).to have_no_button 'Capture' }
    end
  end
end
