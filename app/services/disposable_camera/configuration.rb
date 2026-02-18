module DisposableCamera
  class Configuration
    BUCKET_ENV_KEY = "WEDLY_DISPO_BUCKET".freeze
    REGION_ENV_KEY = "WEDLY_DISPO_REGION".freeze
    PUBLIC_BASE_URL_ENV_KEY = "WEDLY_DISPO_PUBLIC_BASE_URL".freeze

    class << self
      def bucket
        ENV.fetch(BUCKET_ENV_KEY)
      end

      def region
        ENV.fetch(REGION_ENV_KEY, "us-east-1")
      end

      def endpoint
        ENV["WEDLY_DISPO_ENDPOINT"].presence
      end

      def force_path_style?
        ActiveModel::Type::Boolean.new.cast(ENV["WEDLY_DISPO_FORCE_PATH_STYLE"])
      end

      def public_base_url
        ENV[PUBLIC_BASE_URL_ENV_KEY].presence
      end

      def aws_client_config
        config = { region: region }

        config[:access_key_id] = ENV["WEDLY_DISPO_ACCESS_KEY_ID"] if ENV["WEDLY_DISPO_ACCESS_KEY_ID"].present?
        config[:secret_access_key] = ENV["WEDLY_DISPO_SECRET_ACCESS_KEY"] if ENV["WEDLY_DISPO_SECRET_ACCESS_KEY"].present?
        config[:endpoint] = endpoint if endpoint.present?
        config[:force_path_style] = true if force_path_style?

        config
      end
    end
  end
end
