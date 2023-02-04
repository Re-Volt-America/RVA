require "test_helper"

class DownloadsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get downloads_index_url
    assert_response :success
  end
end
