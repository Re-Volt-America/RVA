require "test_helper"

class PlayerStatsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @player_stat = player_stats(:one)
  end

  test "should get index" do
    get player_stats_url
    assert_response :success
  end

  test "should get new" do
    get new_player_stat_url
    assert_response :success
  end

  test "should create player_stat" do
    assert_difference('PlayerStat.count') do
      post player_stats_url, params: { player_stat: { average_position: @player_stat.average_position, obtained_points: @player_stat.obtained_points, official_score: @player_stat.official_score, participation_rate: @player_stat.participation_rate, race_count: @player_stat.race_count, race_wins: @player_stat.race_wins, team_points: @player_stat.team_points } }
    end

    assert_redirected_to player_stat_url(PlayerStat.last)
  end

  test "should show player_stat" do
    get player_stat_url(@player_stat)
    assert_response :success
  end

  test "should get edit" do
    get edit_player_stat_url(@player_stat)
    assert_response :success
  end

  test "should update player_stat" do
    patch player_stat_url(@player_stat), params: { player_stat: { average_position: @player_stat.average_position, obtained_points: @player_stat.obtained_points, official_score: @player_stat.official_score, participation_rate: @player_stat.participation_rate, race_count: @player_stat.race_count, race_wins: @player_stat.race_wins, team_points: @player_stat.team_points } }
    assert_redirected_to player_stat_url(@player_stat)
  end

  test "should destroy player_stat" do
    assert_difference('PlayerStat.count', -1) do
      delete player_stat_url(@player_stat)
    end

    assert_redirected_to player_stats_url
  end
end
