require "test_helper"

module Public
  class SaveTheDatesControllerTest < ActionDispatch::IntegrationTest
    test "show renders invitation video reveal" do
      get public_save_the_date_path
      assert_response :success
      assert_select "[data-controller=invitation-video]"
      assert_select %(video[data-invitation-video-target="video"][src*="britt-alex-envelope-open"])
    end

    test "show with skip_video sets Stimulus value for immediate content" do
      get public_save_the_date_path, params: { skip_video: "1" }
      assert_response :success
      assert_match(/data-invitation-video-skip-video-value="true"/, response.body)
    end
  end
end
