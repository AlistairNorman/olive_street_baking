require 'rails_helper'

RSpec.describe Cookie, type: :model do
  describe "#valid?" do
    subject { cookie.valid? }

    let(:cookie) { build(:cookie) }

    it { is_expected.to eq true }
  end
end
