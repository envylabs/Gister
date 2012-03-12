require_relative 'middleware'

module Gister
  class Railtie < Rails::Railtie
    initializer "gister.configure_rails_initialization" do |app|
      app.middleware.insert_before ActionDispatch::Cookies, Gister::Middleware, Gister.fetcher
    end
  end
end
