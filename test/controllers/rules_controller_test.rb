require "test_helper"

class RulesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get rules_index_url
    assert_response :success
  end

  test "should get terms" do
    get rules_terms_url
    assert_response :success
  end

  test "should get privacy" do
    get rules_privacy_url
    assert_response :success
  end
end
