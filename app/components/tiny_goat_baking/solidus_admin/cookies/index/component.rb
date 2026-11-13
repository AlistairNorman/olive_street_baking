# frozen_string_literal: true

class TinyGoatBaking::SolidusAdmin::Cookies::Index::Component < SolidusAdmin::UI::Pages::Index::Component
  def model_class
    Cookie
  end

  def search_url
    solidus_admin.cookies_path
  end

  def search_key
    :name_or_ingredients_cont
  end

  def edit_path(cookie)
    solidus_admin.edit_cookie_path(cookie, **search_filter_params)
  end

  def turbo_frames
    %w[resource_form]
  end

  def page_actions
    render component("ui/button").new(
      tag: :a,
      text: t(".add"),
      href: solidus_admin.new_cookie_path(**search_filter_params),
      data: { turbo_frame: :resource_form },
      icon: "add-line"
    )
  end

  def batch_actions
    [
      {
        label: t(".batch_actions.delete"),
        action: solidus_admin.cookies_path(**search_filter_params),
        method: :delete,
        icon: "delete-bin-7-line",
        require_confirmation: true
      }
    ]
  end

  def columns
    [
      {
        header: :name,
        data: ->(cookie) do
          link_to cookie.name, edit_path(cookie), data: { turbo_frame: :resource_form }, class: "body-link"
        end
      },
      :ingredients,
      {
        header: :created_at,
        data: ->(cookie) { l(cookie.created_at, format: :short) }
      }
    ]
  end
end
