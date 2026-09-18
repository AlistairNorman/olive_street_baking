# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Checkouts', type: :request, with_signed_in_user: true do
  let(:user) { order.user }

  let(:address_params) do
    address = build(:address)
    address.attributes.except("created_at", "updated_at")
  end
  let(:order) { create(:order_with_line_items) }

  context "#edit" do
    let!(:order) { create(:order_with_line_items) }

    it 'checks if the user is authorized for :edit' do
      get checkout_path, params: { state: "payment" }

      expect(assigns[:order]).to eq order
      expect(status).to eq(200)
    end

    it "redirects to the cart path if checkout_allowed? return false" do
      order.line_items.destroy_all
      get checkout_path, params: { state: "payment" }

      expect(response).to redirect_to(cart_path)
    end

    it "redirects to the cart path if current_order is nil" do
      order.destroy
      get checkout_path, params: { state: "payment" }

      expect(response).to redirect_to(cart_path)
    end

    it "redirects to cart if order is completed" do
      order.touch(:completed_at)
      get checkout_path, params: { state: "payment" }

      expect(response).to redirect_to(cart_path)
    end
  end

  context "#update" do
    let!(:order) { create(:order_with_line_items) }

    it 'checks if the user is authorized for :edit' do
      expect do
        patch update_checkout_path(state: 'payment', order: { email: 'test@email.com' })
      end.to change { order.reload.state }.from('cart').to('payment')
    end

    context "save successful" do
      def post_email
        patch update_checkout_path(state: "payment", order: { email: 'test@email.com' })
      end

      let!(:payment_method) { create(:payment_method) }

      context "when the order in the cart state", partial_double_verification: false do
        let!(:order) { create(:order_with_line_items, state: 'cart') }

        it "assigns order" do
          post_email
          expect(assigns[:order]).not_to be_nil
        end

        it "advances the state" do
          post_email
          expect(order.reload.state).to eq("payment")
        end

        it "redirects the next state" do
          post_email
          expect(response).to redirect_to checkout_state_path("payment")
        end
      end

      # This is the only time that we need the 'set_payment_parameters_amount'
      # controller code, because otherwise the transition to 'complete' will
      # trigger the 'add_store_credit_payments' transition code which will do
      # the same thing here.
      # Perhaps we can just remove 'set_payment_parameters_amount' entirely at
      # some point?
      context "when there is a checkout step after payment", partial_double_verification: false do
        before do
          @old_checkout_flow = Spree::Order.checkout_flow
          Spree::Order.class_eval do
            insert_checkout_step :new_step, after: :payment
          end
        end

        after do
          Spree::Order.checkout_flow(&@old_checkout_flow)
        end

        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:payment_method) { create(:credit_card_payment_method) }

        let(:params) do
          {
            state: 'payment',
            order: {
              payments_attributes: [
                {
                  payment_method_id: payment_method.id.to_s,
                  source_attributes: attributes_for(:credit_card)
                }
              ]
            }
          }
        end

        it 'sets the payment amount' do
          patch update_checkout_path(params)
          order.reload
          expect(order.state).to eq('new_step')
          expect(order.payments.size).to eq(1)
          expect(order.payments.first.amount).to eq(order.total)
        end
      end

      context "when in the payment state" do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:payment_method) { create(:credit_card_payment_method) }

        let(:params) do
          {
            state: 'payment',
            order: {
              payments_attributes: [
                {
                  payment_method_id: payment_method.id.to_s,
                  source_attributes: attributes_for(:credit_card)
                }
              ]
            }
          }
        end

        context 'when a permitted payment method' do
          it 'sets the payment amount' do
            patch update_checkout_path(params)
            order.reload
            expect(order.state).to eq('complete')
            expect(order.payments.size).to eq(1)
            expect(order.payments.first.amount).to eq(order.total)
          end
        end

        context 'when an unpermitted payment method' do
          before { payment_method.update!(available_to_users: false) }

          it 'sets the payment amount' do
            patch update_checkout_path(params)

            expect(response.status).to eq(404)
            expect(order.state).to eq('payment')
            expect(order.payments).to be_empty
          end
        end

        context 'trying to change the address' do
          let(:params) do
            {
              order: {
                payments_attributes: [
                  {
                    payment_method_id: payment_method.id.to_s,
                    source_attributes: attributes_for(:credit_card)
                  }
                ],
                ship_address_attributes: {
                  zipcode: 'TEST'
                }
              }
            }
          end

          it 'does not change the address' do
            expect do
              patch update_checkout_path(state: 'payment', params: params)
            end.not_to(change { order.reload.ship_address.zipcode })
          end
        end
      end

      context "when completing the order" do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:payment_method) { create(:check_payment_method) }

        let(:params) do
          {
            state: 'payment',
            order: {
              payments_attributes: [{ payment_method_id: payment_method.id.to_s }]
            }
          }
        end

        # This inadvertently is a regression test for https://github.com/spree/spree/issues/2694
        it "redirects to the order view" do
          patch update_checkout_path(params)
          expect(response).to redirect_to order_path(order)
        end

        it "populates the flash message" do
          patch update_checkout_path(params)
          expect(flash.notice).to eq(I18n.t('spree.order_processed_successfully'))
        end

        it "removes completed order from current_order" do
          patch update_checkout_path(params)
          expect(assigns(:current_order)).to be_nil
          expect(assigns(:order)).to eql order
        end
      end
    end

    context "save unsuccessful" do
      it "does not assign order" do
        patch update_checkout_path(state: "payment", order: { email: 'test@email.com' })
        expect(assigns[:order]).not_to be_nil
      end

      it "renders the edit template" do
        order.line_items.destroy_all
        patch update_checkout_path(state: "payment", order: { email: 'test@email.com' })
        expect(response).to redirect_to(cart_path)
      end
    end

    context "when current_order id nil" do
      let(:user) { create(:user) }
      let(:order) { create(:order_with_line_items, guest_token: nil, user_id: nil) }

      it "redirects to the cart_path" do
        patch update_checkout_path(state: "payment", order: { email: 'test@email.com' })
        expect(response).to redirect_to cart_path
      end
    end

    context "Spree::Core::GatewayError" do
      let(:order) { create(:order_ready_to_complete, state: 'payment') }
      let(:payment) { order.payments.first }
      let(:updater_instance) { instance_double(Spree::OrderUpdater) }

      before do
        allow(Spree::OrderUpdater).to receive(:new).and_return(updater_instance)
        allow(updater_instance).to receive(:recalculate_payment_state).and_raise(Spree::Core::GatewayError.new('Invalid something or other.'))
        patch update_checkout_path(state: order.state, order: { email: order.email })
      end

      it "renders the edit template and display exception message" do
        expect(response).to render_template :edit
        expect(flash.now[:error]).to eq(I18n.t('spree.spree_gateway_error_flash_for_checkout'))
        expect(assigns(:order).errors[:base]).to include("Invalid something or other.")
      end
    end

    context "when GatewayError is raised" do
      let(:order) { create(:order_ready_to_complete, state: 'payment') }
      let(:payment_source) { order.payments.first.source }

      before { payment_source.destroy! }

      it "fails to transition from payment to complete" do
        patch update_checkout_path(state: order.state, order: { email: order.email })
        expect(flash[:error]).to eq(I18n.t('spree.payment_processing_failed'))
      end
    end

    context "when InsufficientStock error is raised" do
      context "when the order has no shipments" do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:quantifier_instance) { instance_double(Spree::Stock::Quantifier, can_supply?: true) }

        before do
          allow(Spree::OrderUpdateAttributes).to receive(:new).and_raise(Spree::Order::InsufficientStock)
          allow(Spree::Stock::Quantifier).to receive(:new).and_return(quantifier_instance)
          order.shipments.destroy_all
        end

        it "redirects the customer to the cart page with an error message" do
          patch update_checkout_path(state: "payment", order: { email: order.email })
          expect(flash[:error]).to eq(I18n.t('spree.insufficient_stock_for_order'))
          expect(response).to redirect_to(cart_path)
        end
      end

      context "when the order has shipments" do
        let(:order) { create(:order_with_line_items, state: 'payment') }
        let(:availability_validator) { instance_double(Spree::Stock::AvailabilityValidator) }

        context "when items become somehow not available anymore" do
          before do
            allow(Spree::OrderUpdateAttributes).to receive(:new).and_raise(Spree::Order::InsufficientStock)
            allow(Spree::Stock::AvailabilityValidator).to receive(:new) { availability_validator }
            allow(availability_validator).to receive(:validate).and_return(false)
          end

          it "redirects the customer to the payment checkout page with an error message" do
            patch update_checkout_path(state: "payment", order: { email: order.email })
            error = I18n.t('spree.inventory_error_flash_for_insufficient_shipment_quantity', unavailable_items: order.products.first.name)
            expect(flash[:error]).to eq(error)
            expect(response).to redirect_to(checkout_state_path(state: :payment))
          end
        end
      end
    end
  end

  context "When last inventory item has been purchased" do
    let(:order) { create(:order_with_line_items) }

    before do
      stub_spree_preferences(track_inventory_levels: true)
    end

    context "when back orders are not allowed" do
      before do
        order
        Spree::StockItem.update_all(count_on_hand: 0, backorderable: false)
        patch update_checkout_path(state: "payment")
      end

      it "redirects to cart" do
        expect(response).to redirect_to cart_path
      end

      it "redirects set flash message for no inventory" do
        expect(flash[:error]).to eq("#{order.line_items.first.name} became unavailable.")
      end
    end
  end
end
