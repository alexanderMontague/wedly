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

      # S3 DeleteObjects allows up to 1000 keys per request.
      def delete_objects!(object_keys:)
        keys = Array(object_keys).filter_map(&:presence)
        return if keys.empty?

        bucket = DisposableCamera::Configuration.bucket
        keys.each_slice(1000) do |batch|
          response = client.delete_objects(
            bucket: bucket,
            delete: { objects: batch.map { |key| { key: key } }, quiet: true }
          )
          response.errors.each do |err|
            Rails.logger.error(
              "Disposable photo bulk delete failed: key=#{err.key} code=#{err.code} message=#{err.message}"
            )
          end
        end
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
