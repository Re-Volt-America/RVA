require "test_helper"

class TournamentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tournament = tournaments(:one)
  end

  test "should get index" do
    get tournaments_url
    assert_response :success
  end

  test "should get new" do
    get new_tournament_url
    assert_response :success
  end

  test "should create tournament" do
    assert_difference('Tournament.count') do
      post tournaments_url, params: { tournament: { date: @tournament.date, format: @tournament.format, name: @tournament.name } }
    end

    assert_redirected_to tournament_url(Tournament.last)
  end

  test "should show tournament" do
    get tournament_url(@tournament)
    assert_response :success
  end

  test "should get edit" do
    get edit_tournament_url(@tournament)
    assert_response :success
  end

  test "should update tournament" do
    patch tournament_url(@tournament), params: { tournament: { date: @tournament.date, format: @tournament.format, name: @tournament.name } }
    assert_redirected_to tournament_url(@tournament)
  end

  test "should destroy tournament" do
    assert_difference('Tournament.count', -1) do
      delete tournament_url(@tournament)
    end

    assert_redirected_to tournaments_url
  end
end
