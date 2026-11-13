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

    context "on the products list" do
      let(:path) { "/admin/products" }

      it { is_expected.to be false }
    end

    context "on a page whose path only starts like a legacy one" do
      let(:path) { "/admin/orders_archive/R123456789" }

      it { is_expected.to be false }
    end
  end
end
