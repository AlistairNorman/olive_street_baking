# frozen_string_literal: true

SolidusAdmin::Config.configure do |config|
  # Enable alpha features.
  #
  # Do this at your own risk. Alpha features are still in development. Enabling
  # this option will likely break some admin pages and components.
  config.enable_alpha_features = false

  # After solidus_legacy_promotions registers its own orders list.
  Rails.application.config.after_initialize do
    config.components["orders/index"] = "TinyGoatBaking::SolidusAdmin::Orders::Index::Component"
  end

  legacy_admin_paths = [
    %r{\A/admin/orders/.+},
    # The new admin saves stock without going through the API, which is what
    # makes Allie's order.
    %r{\A/admin/stock_items(/|\z)},
    %r{\A/admin/products/[^/]+/(stock|new_bread_variants)(/|\z)}
  ]
  config.force_legacy_admin_proc = ->(request) {
    legacy_admin_paths.any? { |path| path.match?(request.path) }
  }

  # Path to the logo used in the admin interface.
  #
  # It needs to be a path to an image file accessible by Sprockets.
  # config.logo_path = "my_own_logo.svg"

  # Add custom folder paths to watch for changes to trigger a cache sweep forcing a
  # regeneration of the importmap.
  # config.importmap_cache_sweepers << Rails.root.join("app/javascript/my_admin_components")

  # If you want to avoid defining menu_item customizations twice while migrating to SolidusAdmin
  # you can import menu_items from the backend by uncommenting the following line,
  # but you will need to
  # Waits for the Cookies item that config/initializers/spree.rb adds to the
  # legacy menu, since that initializer loads after this one.
  ActiveSupport.on_load(:after_routes_loaded) { config.import_menu_items_from_backend! }

  # Add custom paths to importmap files to be loaded.
  # config.importmap_paths << Rails.root.join("config/solidus_admin_importmap.rb")
  #
  # Configure the main navigation.
  # See SolidusAdmin::MenuItem for more details.
  # config.menu_items << {
  #   key: :my_custom_link,
  #   route: :my_custom_link_path,
  #   icon: "solidus_admin/price-tag-3-line.svg",
  #   position: 80,
  #   children: [
  #     {
  #       key: :my_custom_child_link,
  #       route: :my_custom_child_link_path,
  #       position: 10
  #     }
  #   ]
  # }
end
