module DisposableCamera
  module Storage
    # Contract every disposable camera storage backend must satisfy.
    # Concrete adapters (S3-compatible bucket, local disk) implement these.
    class Adapter
      def upload!(io:, object_key:, content_type:)
        raise NotImplementedError, "#{self.class}#upload! is not implemented"
      end

      def delete!(object_key:)
        raise NotImplementedError, "#{self.class}#delete! is not implemented"
      end

      def delete_objects!(object_keys:)
        raise NotImplementedError, "#{self.class}#delete_objects! is not implemented"
      end

      def public_url_for(object_key)
        raise NotImplementedError, "#{self.class}#public_url_for is not implemented"
      end
    end
  end
end
