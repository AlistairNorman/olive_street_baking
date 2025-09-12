namespace :tiny do
  task new_breads: :environment do
    pickup_date_type = Spree::OptionType.find_by(name: 'Pickup Date')
    bread = Spree::Product.sole

    last_pickup_date = pickup_date_type.option_values.max { |value|
      value.name.to_date
    }.name.to_date

    10.times do |i|
      next_pickup_date = last_pickup_date + 7.days

      option_value = pickup_date_type.option_values.create!(
        name: next_pickup_date.strftime('%B %d, %Y'),
        presentation: next_pickup_date.strftime('%B %d, %Y')
      )
      Spree::Variant.create!(
        product: bread,
        option_values: [option_value]
      )

      last_pickup_date = next_pickup_date
    end
  end
end
