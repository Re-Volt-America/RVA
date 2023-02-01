require "application_system_test_case"

class PlayerStatsTest < ApplicationSystemTestCase
  setup do
    @player_stat = player_stats(:one)
  end

  test "visiting the index" do
    visit player_stats_url
    assert_selector "h1", text: "Player Stats"
  end

  test "creating a Player stat" do
    visit player_stats_url
    click_on "New Player Stat"

    fill_in "Average position", with: @player_stat.average_position
    fill_in "Obtained points", with: @player_stat.obtained_points
    fill_in "Official score", with: @player_stat.official_score
    fill_in "Participation rate", with: @player_stat.participation_rate
    fill_in "Race count", with: @player_stat.race_count
    fill_in "Race wins", with: @player_stat.race_wins
    fill_in "Team points", with: @player_stat.team_points
    click_on "Create Player stat"

    assert_text "Player stat was successfully created"
    click_on "Back"
  end

  test "updating a Player stat" do
    visit player_stats_url
    click_on "Edit", match: :first

    fill_in "Average position", with: @player_stat.average_position
    fill_in "Obtained points", with: @player_stat.obtained_points
    fill_in "Official score", with: @player_stat.official_score
    fill_in "Participation rate", with: @player_stat.participation_rate
    fill_in "Race count", with: @player_stat.race_count
    fill_in "Race wins", with: @player_stat.race_wins
    fill_in "Team points", with: @player_stat.team_points
    click_on "Update Player stat"

    assert_text "Player stat was successfully updated"
    click_on "Back"
  end

  test "destroying a Player stat" do
    visit player_stats_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Player stat was successfully destroyed"
  end
end
