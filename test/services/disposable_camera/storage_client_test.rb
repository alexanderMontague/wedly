require "test_helper"

module DisposableCamera
  class StorageClientTest < ActiveSupport::TestCase
    teardown { StorageClient.reset_adapter! }

    test "selects the local adapter when local storage is enabled" do
      StorageClient.reset_adapter!

      Configuration.stub(:local_storage?, true) do
        assert_instance_of Storage::LocalAdapter, StorageClient.adapter
      end
    end

    test "selects the s3 adapter when local storage is disabled" do
      StorageClient.reset_adapter!

      Configuration.stub(:local_storage?, false) do
        assert_instance_of Storage::S3Adapter, StorageClient.adapter
      end
    end

    test "memoizes the adapter until reset" do
      StorageClient.reset_adapter!

      Configuration.stub(:local_storage?, true) do
        assert_same StorageClient.adapter, StorageClient.adapter
      end
    end

    test "delegates public_url_for to the selected adapter" do
      fake_adapter = Minitest::Mock.new
      fake_adapter.expect(:public_url_for, "https://example.test/key", ["key"])

      StorageClient.stub(:adapter, fake_adapter) do
        assert_equal "https://example.test/key", StorageClient.public_url_for("key")
      end

      fake_adapter.verify
    end

    test "delegates upload! to the selected adapter" do
      fake_adapter = Minitest::Mock.new
      io = StringIO.new("x")
      fake_adapter.expect(:upload!, true, io: io, object_key: "key", content_type: "image/jpeg")

      StorageClient.stub(:adapter, fake_adapter) do
        StorageClient.upload!(io: io, object_key: "key", content_type: "image/jpeg")
      end

      fake_adapter.verify
    end
  end
end
