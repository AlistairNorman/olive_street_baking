module TinyGoatBaking
  module Admin
    module OrderPickupDates
      ::Deface::Override.new(
        virtual_path: 'spree/admin/orders/index',
        name: 'order_pickup_dates_header',
        insert_before: '[data-hook="admin_orders_index_headers"] th:contains("sort_link @search, :state")',
        text: "<th><%= t('tiny_goat_baking.order_pickup_dates.header') %></th>"
      )

      ::Deface::Override.new(
        virtual_path: 'spree/admin/orders/index',
        name: 'order_pickup_dates_cell',
        insert_after: '[data-hook="admin_orders_index_rows"] td:contains("link_to order.number")',
        partial: 'spree/admin/orders/pickup_dates'
      )
    end
  end
end
