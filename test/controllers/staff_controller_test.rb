require "test_helper"

class StaffControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get staff_index_url
    assert_response :success
  end
end
