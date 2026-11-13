# frozen_string_literal: true

class TinyGoatBaking::SolidusAdmin::Orders::Index::Component < SolidusLegacyPromotions::Orders::Index::Component
  def columns
    super.insert(1, pickup_date_column) + [payment_method_column, capture_column]
  end

  def pickup_date_column
    {
      header: -> { pickup_date_sort_link },
      data: ->(order) do
        safe_join(order.pickup_dates.map { |pickup_date| tag.div(TinyGoatBaking::PickupDate.display(pickup_date)) })
      end
    }
  end

  def payment_method_column
    {
      header: t("tiny_goat_baking.order_payment_methods.header"),
      data: ->(order) { order.payments.valid.first&.payment_method&.name }
    }
  end

  def capture_column
    {
      header: tag.span(t("tiny_goat_baking.order_payment_captures.button"), class: "sr-only"),
      data: ->(order) { capture_button(order) if capturable?(order) }
    }
  end

  private

  def pickup_date_sort_link
    direction = search_params&.dig(:s) == "pickup_date asc" ? "desc" : "asc"
    query = request.query_parameters.except("page")
    query["q"] = query.fetch("q", {}).merge("s" => "pickup_date #{direction}")

    link_to t("tiny_goat_baking.order_pickup_dates.header"), solidus_admin.orders_path(query), class: "body-link"
  end

  def capturable?(order)
    order.completed? &&
      order.payment_state == "balance_due" &&
      order.capturable_payments.any? &&
      helpers.can?(:capture, Spree::Payment)
  end

  def capture_button(order)
    form_with url: spree.admin_order_payment_capture_path(order), method: :post do
      render component("ui/button").new(
        type: :submit,
        text: t("tiny_goat_baking.order_payment_captures.button"),
        size: :s,
        scheme: :secondary,
        "data-turbo-confirm": t("tiny_goat_baking.order_payment_captures.confirm", number: order.number, total: order.display_total),
        "data-confirm-button": t("tiny_goat_baking.order_payment_captures.button")
      )
    end
  end
end
