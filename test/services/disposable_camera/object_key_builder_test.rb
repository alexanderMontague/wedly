require "test_helper"

module DisposableCamera
  class ObjectKeyBuilderTest < ActiveSupport::TestCase
    test "builds object keys with environment and wedding code" do
      object_key = ObjectKeyBuilder.build(wedding_code: "britt-and-alex", content_type: "image/jpeg")

      assert_match(
        %r{\Atest/britt-and-alex/photos/\d{8}-\d{6}-[0-9a-f]{16}\.jpg\z},
        object_key
      )
    end

    test "raises for unsupported content type" do
      assert_raises(ArgumentError) do
        ObjectKeyBuilder.build(wedding_code: "britt-and-alex", content_type: "image/gif")
      end
    end
  end
end
