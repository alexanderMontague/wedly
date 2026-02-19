require "aws-sdk-s3"
require "uri"

module DisposableCamera
  class StorageClient
    ACL_PUBLIC_READ = "public-read".freeze

    class << self
      def upload!(io:, object_key:, content_type:)
        client.put_object(
          bucket: DisposableCamera::Configuration.bucket,
          key: object_key,
          body: io,
          acl: ACL_PUBLIC_READ,
          content_type: content_type
        )
      end

      def delete!(object_key:)
        client.delete_object(
          bucket: DisposableCamera::Configuration.bucket,
          key: object_key
        )
      end

      def public_url_for(object_key)
        if DisposableCamera::Configuration.public_base_url.present?
          return "#{DisposableCamera::Configuration.public_base_url}/#{object_path_for_public_base_url(object_key)}"
        end

        if tigris_public_base_url.present?
          return "#{tigris_public_base_url}/#{object_key}"
        end

        if DisposableCamera::Configuration.endpoint.present?
          return "#{DisposableCamera::Configuration.endpoint}/#{DisposableCamera::Configuration.bucket}/#{object_key}"
        end

        "https://#{DisposableCamera::Configuration.bucket}.s3.#{DisposableCamera::Configuration.region}.amazonaws.com/#{object_key}"
      end

      private

      def client
        @client ||= Aws::S3::Client.new(**DisposableCamera::Configuration.aws_client_config)
      end

      def object_path_for_public_base_url(object_key)
        return object_key if public_base_url_includes_bucket?

        "#{DisposableCamera::Configuration.bucket}/#{object_key}"
      end

      def public_base_url_includes_bucket?
        uri = URI.parse(DisposableCamera::Configuration.public_base_url)
        uri.host&.start_with?("#{DisposableCamera::Configuration.bucket}.")
      rescue URI::InvalidURIError
        false
      end

      def tigris_public_base_url
        uri = URI.parse(DisposableCamera::Configuration.endpoint.to_s)
        return nil unless uri.host == "fly.storage.tigris.dev"

        "#{uri.scheme}://#{DisposableCamera::Configuration.bucket}.#{uri.host}"
      rescue URI::InvalidURIError
        nil
      end
    end
  end
end
