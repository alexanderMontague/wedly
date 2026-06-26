# Single source of truth for outbound SMTP transport, shared by every
# environment that delivers over SMTP (development, production). Runs after the
# per-environment config has set `delivery_method`, so test/other adapters are
# left untouched.
#
# Port 465 speaks implicit TLS (SMTPS) from the first byte, while 587 negotiates
# encryption via STARTTLS. Choosing the wrong one silently fails the handshake,
# so the transport flags are derived from the configured port.
Rails.application.configure do
  next unless config.action_mailer.delivery_method == :smtp

  smtp_port = ENV.fetch("SMTP_PORT", 587).to_i
  implicit_tls = smtp_port == 465

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", nil),
    port: smtp_port,
    user_name: ENV.fetch("SMTP_USERNAME", nil),
    password: ENV.fetch("SMTP_PASSWORD", nil),
    authentication: :login,
    enable_starttls_auto: !implicit_tls,
    tls: implicit_tls
  }
end
