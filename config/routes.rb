Rails.application.routes.draw do
  mount SolidusAdmin::Engine, at: '/admin', constraints: ->(req) {
    req.cookies['solidus_admin'] != 'false' &&
    req.params['solidus_admin'] != 'false' &&
    !SolidusAdmin::Config.force_legacy_admin_proc.call(req)
  }
  mount SolidusStripe::Engine, at: '/solidus_stripe'
  scope(path: '/') { draw :storefront }
  # This line mounts Solidus's routes at the root of your application.
  #
  # Unless you manually picked only a subset of Solidus components, this will mount routes for:
  #   - solidus_backend
  #   - solidus_api
  # This means, any requests to URLs such as /admin/products, will go to Spree::Admin::ProductsController.
  #
  # If you are using the Starter Frontend as your frontend, be aware that all the storefront routes are defined
  # separately in this file and are not part of the Solidus::Core::Engine engine.
  #
  # If you would like to change where this engine is mounted, simply change the :at option to something different.
  # We ask that you don't use the :as option here, as Solidus relies on it being the default of "spree"
  mount Spree::Core::Engine, at: '/'

  SolidusAdmin::Engine.routes.draw do
    require "solidus_admin/admin_resources"
    extend SolidusAdmin::AdminResources

    admin_resources :cookies, except: [:show], controller: "/admin/cookies"
  end

  Spree::Core::Engine.routes.draw do
    namespace :admin do
      post '/products/:product_slug/new_bread_variants',
           to: 'new_bread_variants#create',
           as: :product_new_bread_variants
      post '/orders/:order_id/payment_capture',
           to: 'order_payment_captures#create',
           as: :order_payment_capture
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
