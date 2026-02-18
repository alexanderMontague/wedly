module DisposableCamera
  class ObjectKeyBuilder
    DIRECTORY_PREFIX = "wedly/disposable".freeze

    class << self
      def build(wedding_id:, content_type:)
        extension = extension_for(content_type)
        timestamp = Time.current.utc.strftime("%Y%m%d-%H%M%S")
        nonce = SecureRandom.hex(8)

        "#{DIRECTORY_PREFIX}/#{wedding_id}/#{timestamp}-#{nonce}.#{extension}"
      end

      private

      def extension_for(content_type)
        case content_type
        when "image/jpeg" then "jpg"
        when "image/png" then "png"
        when "image/webp" then "webp"
        else
          raise ArgumentError, "Unsupported content type: #{content_type.inspect}"
        end
      end
    end
  end
end
