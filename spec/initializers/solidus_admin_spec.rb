# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SolidusAdmin::Config do
  describe ".force_legacy_admin_proc" do
    subject { described_class.force_legacy_admin_proc.call(request) }

    let(:request) { ActionDispatch::Request.new(Rack::MockRequest.env_for(path)) }

    context "on the orders list" do
      let(:path) { "/admin/orders" }

      it { is_expected.to be false }
    end

    context "on an order's pages" do
      let(:path) { "/admin/orders/R123456789/edit" }

      it { is_expected.to be true }
    end

    context "when capturing an order's payment" do
      let(:path) { "/admin/orders/R123456789/payment_capture" }

      it { is_expected.to be true }
    end

    context "on the stock items list" do
      let(:path) { "/admin/stock_items" }

      it { is_expected.to be false }
    end

    context "on a product's stock page" do
      let(:path) { "/admin/products/sourdough/stock" }

      it { is_expected.to be true }
    end

    context "when adding new bread variants" do
      let(:path) { "/admin/products/sourdough/new_bread_variants" }

      it { is_expected.to be true }
    end

    context "on the products list" do
      let(:path) { "/admin/products" }

      it { is_expected.to be false }
    end

    context "on a page whose path only starts like a legacy one" do
      let(:path) { "/admin/products/sourdough/stock_history" }

      it { is_expected.to be false }
    end
  end
end
