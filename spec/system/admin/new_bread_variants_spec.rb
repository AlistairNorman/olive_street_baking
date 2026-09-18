# frozen_string_literal: true

require 'solidus_starter_frontend_spec_helper'

RSpec.describe 'Adding new bread variants from the admin stock page', type: :system do
  stub_authorization!

  let!(:product) { create(:product, name: 'Sourdough') }
  let!(:pickup_date_type) { create(:option_type, name: 'Pickup Date', presentation: 'Pickup Date') }

  def pickup_dates
    pickup_date_type.option_values.reload.map { |option_value| option_value.name.to_date }
  end

  context 'when pickup dates already exist' do
    before do
      ['January 03, 2026', 'January 17, 2026', 'January 10, 2026'].each do |name|
        pickup_date_type.option_values.create!(name: name, presentation: name)
      end
    end

    it 'creates ten weekly variants following the latest pickup date' do
      visit spree.admin_product_stock_path(product)
      click_button 'Add 10 more weeks'

      expect(page).to have_content 'Added 10 more weeks of breads.'

      expected = (1..10).map { |week| Date.new(2026, 1, 17) + (week * 7) }
      expect(pickup_dates).to match_array([Date.new(2026, 1, 3), Date.new(2026, 1, 10), Date.new(2026, 1, 17)] + expected)
    end

    it 'attaches each new pickup date to the product as a variant' do
      visit spree.admin_product_stock_path(product)

      expect { click_button 'Add 10 more weeks' }
        .to change { product.variants.reload.count }.by(10)

      newest = product.variants.reload.max_by(&:id)
      expect(newest.option_values.map(&:name)).to eq(['March 28, 2026'])
    end
  end

  context 'when no pickup dates exist yet' do
    it 'reports that there is nothing to add breads after' do
      visit spree.admin_product_stock_path(product)
      click_button 'Add 10 more weeks'

      expect(page).to have_content 'There are no pickup dates to add new breads after.'
      expect(product.variants.reload).to be_empty
    end
  end
end
