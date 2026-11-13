# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe Spree::OrderMailer, type: :mailer do
  describe ".confirm_email" do
    subject { described_class.confirm_email(order).body.encoded }

    let(:order) { create :order_ready_to_ship, line_items_attributes: line_items_attributes }
    let(:pickup_date_type) { create :option_type, name: "Pickup Date", presentation: "Pickup Date" }

    def bread_variant(pickup_date:)
      option_value = create :option_value,
        option_type: pickup_date_type,
        name: pickup_date.strftime("%B %d, %Y")
      create :variant, option_values: [option_value]
    end

    context "when every loaf is for the same pickup date" do
      let(:line_items_attributes) { [{ variant: bread_variant(pickup_date: Date.new(2026, 11, 7)), quantity: 2 }] }

      it { is_expected.to include "ready for pickup on Saturday, November 7, 2026 by 9am" }
      it { is_expected.to include "Pickup Date: Sat, Nov 7, 2026" }
    end

    context "when the loaves are for different pickup dates" do
      let(:line_items_attributes) {
        [
          { variant: bread_variant(pickup_date: Date.new(2026, 11, 21)), quantity: 1 },
          { variant: bread_variant(pickup_date: Date.new(2026, 11, 14)), quantity: 1 }
        ]
      }

      it { is_expected.to match(/Saturday, November 14, 2026.*Saturday, November 21, 2026/m) }
    end

    context "when no loaf has a pickup date" do
      let(:line_items_attributes) { [{ variant: create(:variant), quantity: 1 }] }

      it { is_expected.not_to include "ready for pickup" }
    end
  end
end
