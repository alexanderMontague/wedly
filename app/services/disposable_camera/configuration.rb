module DisposableCamera
  class Configuration
    BUCKET_ENV_KEY = "BUCKET_NAME".freeze
    REGION_ENV_KEY = "AWS_REGION".freeze
    PUBLIC_BASE_URL_ENV_KEY = "AWS_ENDPOINT_URL_S3".freeze
    SSL_VERIFY_PEER_ENV_KEY = "AWS_SSL_VERIFY_PEER".freeze
    SSL_CA_BUNDLE_ENV_KEY = "AWS_SSL_CA_BUNDLE".freeze

    class << self
      def bucket
        ENV.fetch(BUCKET_ENV_KEY)
      end

      def region
        ENV.fetch(REGION_ENV_KEY, "us-east-1")
      end

      def endpoint
        ENV["AWS_ENDPOINT_URL_S3"].presence
      end

      def force_path_style?
        ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_PATH_STYLE", nil))
      end

      def public_base_url
        ENV[PUBLIC_BASE_URL_ENV_KEY].presence
      end

      def ssl_verify_peer?
        explicit_value = ENV[SSL_VERIFY_PEER_ENV_KEY]
        return ActiveModel::Type::Boolean.new.cast(explicit_value) if explicit_value.present?

        return false if endpoint.present? && !Rails.env.production?

        true
      end

      def ssl_ca_bundle
        ENV[SSL_CA_BUNDLE_ENV_KEY].presence
      end

      def aws_client_config
        config = { region: region }

        config[:access_key_id] = ENV["AWS_ACCESS_KEY_ID"] if ENV["AWS_ACCESS_KEY_ID"].present?
        if ENV["AWS_SECRET_ACCESS_KEY"].present?
          config[:secret_access_key] =
            ENV["AWS_SECRET_ACCESS_KEY"]
        end
        config[:endpoint] = endpoint if endpoint.present?
        config[:force_path_style] = true if force_path_style?
        config[:ssl_verify_peer] = ssl_verify_peer?
        config[:ssl_ca_bundle] = ssl_ca_bundle if ssl_ca_bundle.present?

        config
      end
    end
  end
end
