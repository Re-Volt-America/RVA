require "test_helper"

class PlayControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get play_index_url
    assert_response :success
  end
end
