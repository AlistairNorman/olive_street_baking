RSpec.configure do |config|
  config.use_transactional_fixtures = true

  # TODO Remove when Devise fixes https://github.com/heartcombo/devise/issues/5705
  config.before(:each, type: :controller) do
    Rails.application.reload_routes_unless_loaded
  end
  config.before(:each, type: :request) do
    Rails.application.reload_routes_unless_loaded
  end
end
