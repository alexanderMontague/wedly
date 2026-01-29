require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  config.assets.compile = false

  config.active_storage.service = :local

  config.force_ssl = true

  config.log_level = :info
  config.log_tags = [:request_id]

  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: ENV["APP_HOST"], protocol: 'https' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address: ENV["SMTP_ADDRESS"],
    port: ENV.fetch("SMTP_PORT", 587),
    user_name: ENV["SMTP_USERNAME"],
    password: ENV["SMTP_PASSWORD"],
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false
end
