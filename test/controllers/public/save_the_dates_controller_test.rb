require "test_helper"

module Public
  class SaveTheDatesControllerTest < ActionDispatch::IntegrationTest
    test "show renders invitation video reveal" do
      get public_save_the_date_path
      assert_response :success
      assert_select "[data-controller=invitation-video]"
      assert_select %(video[data-invitation-video-target="video"][src*="britt"])
    end
  end
end
