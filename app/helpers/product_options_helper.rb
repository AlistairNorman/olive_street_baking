# frozen_string_literal: true

module ProductOptionsHelper
  def product_variants_with_options(product)
    product.variants_and_option_values_for(current_pricing_options)
  end

  def default_variant(product)
    product_variants_with_options(product).find(&:in_stock?) || product.master
  end

  def sorted_option_values(variant)
    variant.option_values.sort_by { |value| value.option_type.position }.map(&:id)
  end

  def sorted_option_types(product)
    product.option_types.sort_by(&:position)
  end

  def upcoming_bakes(product)
    @upcoming_bakes ||= {}
    @upcoming_bakes[product.id] ||= product.variants.select(&:upcoming_bake?).sort_by(&:pickup_date)
  end

  def pickup_date_label(variant)
    label = TinyGoatBaking::PickupDate.display(variant.pickup_date)
    variant.in_stock? ? label : "#{label} (sold out)"
  end

  def pickup_date_options(product)
    options_for_select(
      upcoming_bakes(product).map { |variant|
        [pickup_date_label(variant), variant.pickup_date_option_value.id, { disabled: !variant.in_stock? }]
      }
    )
  end
end
