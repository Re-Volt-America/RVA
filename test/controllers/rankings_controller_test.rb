require "test_helper"

class RankingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ranking = rankings(:one)
  end

  test "should get index" do
    get rankings_url
    assert_response :success
  end

  test "should get new" do
    get new_ranking_url
    assert_response :success
  end

  test "should create ranking" do
    assert_difference('Ranking.count') do
      post rankings_url, params: { ranking: { number: @ranking.number } }
    end

    assert_redirected_to ranking_url(Ranking.last)
  end

  test "should show ranking" do
    get ranking_url(@ranking)
    assert_response :success
  end

  test "should get edit" do
    get edit_ranking_url(@ranking)
    assert_response :success
  end

  test "should update ranking" do
    patch ranking_url(@ranking), params: { ranking: { number: @ranking.number } }
    assert_redirected_to ranking_url(@ranking)
  end

  test "should destroy ranking" do
    assert_difference('Ranking.count', -1) do
      delete ranking_url(@ranking)
    end

    assert_redirected_to rankings_url
  end
end
