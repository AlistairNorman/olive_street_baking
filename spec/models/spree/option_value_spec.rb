# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spree::OptionValue, type: :model do
  let(:pickup_date_type) { create :option_type, name: "Pickup Date" }
  let(:option_value) { build :option_value, option_type: pickup_date_type, name: name }
  let(:name) { "Wed, Nov 11, 2026" }

  describe "#valid?" do
    subject { option_value.valid? }

    it { is_expected.to be true }

    context "when the name isn't a date" do
      let(:name) { "Next Wednesday" }

      it { is_expected.to be false }
    end

    context "when the weekday doesn't match the date" do
      let(:name) { "Thu, Nov 11, 2026" }

      it { is_expected.to be false }
    end

    context "when it isn't a pickup date" do
      let(:option_value) { build :option_value, name: "Large" }

      it { is_expected.to be true }
    end
  end

  describe "#save" do
    subject { option_value.save }

    it "stores the date from the name" do
      expect { subject }.to change { option_value.pickup_date }.from(nil).to(Date.new(2026, 11, 11))
    end

    context "when the name has the full month and no weekday" do
      let(:name) { "November 4, 2026" }

      it "stores the date from the name" do
        expect { subject }.to change { option_value.pickup_date }.from(nil).to(Date.new(2026, 11, 4))
      end
    end

    context "when the name is changed to another day" do
      before { option_value.save! }

      it "moves the date with it" do
        option_value.name = "Thu, Nov 12, 2026"

        expect { subject }.to change { option_value.pickup_date }.to(Date.new(2026, 11, 12))
      end
    end
  end
end
