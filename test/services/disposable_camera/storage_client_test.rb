require "test_helper"

module DisposableCamera
  class StorageClientTest < ActiveSupport::TestCase
    test "builds tigris bucket-subdomain public url when endpoint is configured" do
      with_environment(
        "BUCKET_NAME" => "wedly",
        "AWS_ENDPOINT_URL_S3" => "https://fly.storage.tigris.dev",
        "DISPOSABLE_CAMERA_PUBLIC_BASE_URL" => nil
      ) do
        object_key = "test/britt-and-alex/photos/example.jpg"

        assert_equal(
          "https://wedly.fly.storage.tigris.dev/#{object_key}",
          StorageClient.public_url_for(object_key)
        )
      end
    end

    test "builds public base url with bucket and key" do
      with_environment(
        "BUCKET_NAME" => "wedly",
        "DISPOSABLE_CAMERA_PUBLIC_BASE_URL" => "https://cdn.example.com"
      ) do
        object_key = "test/britt-and-alex/photos/example.jpg"

        assert_equal(
          "https://cdn.example.com/wedly/#{object_key}",
          StorageClient.public_url_for(object_key)
        )
      end
    end

    test "does not prepend bucket when public base url already includes it" do
      with_environment(
        "BUCKET_NAME" => "wedly",
        "DISPOSABLE_CAMERA_PUBLIC_BASE_URL" => "https://wedly.cdn.example.com"
      ) do
        object_key = "test/britt-and-alex/photos/example.jpg"

        assert_equal(
          "https://wedly.cdn.example.com/#{object_key}",
          StorageClient.public_url_for(object_key)
        )
      end
    end

    test "deletes object by key from configured bucket" do
      with_environment("BUCKET_NAME" => "wedly") do
        fake_client = Minitest::Mock.new
        fake_client.expect(
          :delete_object,
          true,
          [{ bucket: "wedly", key: "test/britt-and-alex/photos/example.jpg" }]
        )

        StorageClient.stub(:client, fake_client) do
          StorageClient.delete!(object_key: "test/britt-and-alex/photos/example.jpg")
        end

        fake_client.verify
      end
    end

    test "deletes multiple objects in batches via delete_objects" do
      with_environment("BUCKET_NAME" => "wedly") do
        calls = []
        fake_client = Object.new
        fake_client.define_singleton_method(:delete_objects) do |params|
          calls << params
          Aws::S3::Types::DeleteObjectsOutput.new(errors: [])
        end

        StorageClient.stub(:client, fake_client) do
          StorageClient.delete_objects!(object_keys: %w[a.jpg b.jpg])
        end

        assert_equal 1, calls.size
        assert_equal "wedly", calls.first[:bucket]
        assert_equal %w[a.jpg b.jpg], calls.first[:delete][:objects].pluck(:key)
      end
    end

    private

    def with_environment(overrides)
      original_values = overrides.keys.to_h { |key| [key, ENV[key]] }

      overrides.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end

      yield
    ensure
      original_values.each do |key, value|
        value.nil? ? ENV.delete(key) : ENV[key] = value
      end
    end
  end
end
