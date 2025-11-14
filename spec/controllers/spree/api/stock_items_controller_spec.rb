# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::Api::StockItemsController, type: :request do
  describe 'PATCH #update' do
    subject {
      put path,
        params: {
          stock_item: {
            count_on_hand: 4
          }
        }
    }

    let(:path) {
      spree.api_stock_location_stock_item_path(
        stock_location, stock_item
      )
    }
    let!(:variant) { create(:variant) }
    let!(:stock_location) { variant.stock_locations.first }
    let(:stock_item) { variant.stock_items.first }
    let(:allie) { create :user, email: "allie@example.com" }
    let(:current_api_user) { create :admin_user }

    before do
      create :check_payment_method
      create :completed_order_with_totals,
        line_items_attributes: [{ variant: create(:variant), quantity: 1 }],
        user: allie

      allow(Spree::User).to receive(:find_by).with(email: "allie@example.com") { allie }
      allow(Spree.user_class)
        .to receive(:find_by)
        .with(hash_including(:spree_api_key)) { current_api_user }
    end

    context "when the variant already has an order for Allie" do
      before do
        create :completed_order_with_totals,
          line_items_attributes: [{ variant: variant, quantity: 1 }],
          user: allie
      end

      it "doesn't create a new order for her" do
        expect { subject }
          .not_to change { Spree::Order.count }
          .from(2)
      end
    end

    context "when the variant does not have any orders for Allie" do
      it "creates a new order for her" do
        expect { subject }
          .to change { Spree::Order.complete.count }
          .from(1)
          .to(2)

        expect(Spree::Order.last.user).to eq(allie)
        expect(Spree::Order.last.line_items.sole).to have_attributes(
          variant: variant,
          quantity: 1
        )
      end

      context "when Allie has store credit" do
        before do
          create :store_credit, amount: 20, user: allie, currency: "CAD"
          create :store_credit_payment_method, auto_capture: true
        end

        it "creates a new order for her and applies store credit" do
          expect { subject }
            .to change { allie.reload.store_credits.sole.amount_used }
            .from(0)
            .to(19.99)

          expect(Spree::Order.complete.last.user).to eq(allie)
        end
      end
    end
  end
end
