module Admin
  class CookiesController < ::Spree::Admin::ResourceController
    def index
    end

    private

    def model_class
      Cookie
    end

    def routes_proxy
      self
    end
  end
end
