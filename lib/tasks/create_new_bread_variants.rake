namespace :tiny do
  task new_breads: :environment do
    TinyGoatBaking::CreateNewBreadVariants.call(product: Spree::Product.sole)
  end
end
