# frozen_string_literal: true

RSpec.shared_context "featured products" do
  before(:each) do
    create(:store)
    categories = create(:taxonomy, name: 'Categories')
    categories_root = categories.root
    clothing_taxon = create(:taxon, name: 'Clothing', parent_id: categories_root.id, taxonomy: categories)
    image = create(:image)

    product = create(:custom_product, name: 'Solidus hoodie', price: '29.99', taxons: [clothing_taxon])
    variant = create(:variant, product: product, images: [image, image])
    variant.stock_items.each { |stock_item| stock_item.set_count_on_hand(10) }
  end
end
