module TinyGoatBaking
  module Admin
    module OrderTimestamps
      ::Deface::Override.new(
        virtual_path: 'spree/admin/shared/_order_summary',
        name: 'order_timestamps',
        insert_bottom: 'dl.additional-info',
        partial: 'spree/admin/orders/timestamps'
      )
    end
  end
end
