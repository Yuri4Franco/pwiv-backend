require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PwBackend
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Adicione manualmente o middleware do Rack::Cors
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*' # Substitua '*' pelo domínio do frontend, ex: 'http://localhost:3000'
        resource '*',
                 headers: :any,
                 methods: [:get, :post, :put, :patch, :delete, :options, :head]
      end
    end

    # API only: mantém apenas o necessário para APIs
    config.api_only = true
  end
end
