# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Payment methods on the admin orders page', type: :system do
  before { sign_in create(:admin_user) }

  let!(:order) { create :completed_order_with_totals }

  before do
    create :payment, order: order, amount: order.total, payment_method: create(:check_payment_method, name: "Cheque")
  end

  it "shows how each order is being paid for" do
    visit solidus_admin.orders_path

    expect(page).to have_css "th", text: "Payment Method"
    within("tr", text: order.number) { expect(page).to have_content "Cheque" }
  end
end
