require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Código não é recarregado entre requisições
  config.enable_reloading = false

  # para o sidekiq
  config.active_job.queue_adapter = :solid_queue
  config.solid_queue.connects_to = { database: { writing: :queue } }

  config.eager_load = true

  config.consider_all_requests_local = false

  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=#{1.year.to_i}"
  }

  config.active_storage.service = :local


  config.force_ssl = false
  config.assume_ssl = true

  # Hosts permitidos — domínio e IP do servidor
  config.hosts = [
    /.*dairysense\.com\.br/,
    "209.38.139.252"
  ]

  # definicao dos proxies
  config.action_dispatch.trusted_proxies = [
    IPAddr.new("10.0.0.0/8"),      # Rede Docker
    IPAddr.new("172.16.0.0/12"),   # Rede Docker
    IPAddr.new("192.168.0.0/16"),  # Rede local
    IPAddr.new("173.245.48.0/20"), # Cloudflare
    IPAddr.new("103.21.244.0/22"),
    IPAddr.new("103.22.200.0/22"),
    IPAddr.new("103.31.4.0/22"),
    IPAddr.new("141.101.64.0/18"),
    IPAddr.new("108.162.192.0/18"),
    IPAddr.new("190.93.240.0/20"),
    IPAddr.new("188.114.96.0/20"),
    IPAddr.new("197.234.240.0/22"),
    IPAddr.new("198.41.128.0/17")
  ]



  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false



  config.cache_store = :solid_cache_store

  config.active_job.queue_adapter = :sidekiq



  config.action_mailer.default_url_options = { host: "dairysense.com.br", protocol: "https" }
  # config.action_mailer.smtp_settings = {
  #   user_name: Rails.application.credentials.dig(:smtp, :user_name),
  #   password:  Rails.application.credentials.dig(:smtp, :password),
  #   address:   "smtp.seuprovedor.com",
  #   port:      587,
  #   authentication: :plain
  # }



  config.i18n.fallbacks = true


  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [ :id ]


  config.middleware.use ActionDispatch::Cookies
  config.middleware.use ActionDispatch::Session::CookieStore,
                        key: "_dairysense_session",
                        same_site: :lax,
                        secure: true
end
