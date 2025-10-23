require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BackendDairySense
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0



    config.autoload_lib(ignore: %w[assets tasks])

    config.api_only = true

    # Set timezone to Brasilia (UTC-3)
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :local

    # API-only com sessão p/ Sidekiq Web
    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore,
                          key: "_dairysense_session",
                          same_site: :lax,
                          secure: Rails.env.production?
  end
end
