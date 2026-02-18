require "aws-sdk-s3"

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

      def public_url_for(object_key)
        return "#{DisposableCamera::Configuration.public_base_url}/#{object_key}" if DisposableCamera::Configuration.public_base_url.present?

        if DisposableCamera::Configuration.endpoint.present?
          return "#{DisposableCamera::Configuration.endpoint}/#{DisposableCamera::Configuration.bucket}/#{object_key}"
        end

        "https://#{DisposableCamera::Configuration.bucket}.s3.#{DisposableCamera::Configuration.region}.amazonaws.com/#{object_key}"
      end

      private

      def client
        @client ||= Aws::S3::Client.new(**DisposableCamera::Configuration.aws_client_config)
      end
    end
  end
end
