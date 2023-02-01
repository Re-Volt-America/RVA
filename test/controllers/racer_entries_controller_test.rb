require "test_helper"

class RacerEntriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @racer_entry = racer_entries(:one)
  end

  test "should get index" do
    get racer_entries_url
    assert_response :success
  end

  test "should get new" do
    get new_racer_entry_url
    assert_response :success
  end

  test "should create racer_entry" do
    assert_difference('RacerEntry.count') do
      post racer_entries_url, params: { racer_entry: { best_lap: @racer_entry.best_lap, car: @racer_entry.car, cheating: @racer_entry.cheating, finished: @racer_entry.finished, name: @racer_entry.name, team: @racer_entry.team } }
    end

    assert_redirected_to racer_entry_url(RacerEntry.last)
  end

  test "should show racer_entry" do
    get racer_entry_url(@racer_entry)
    assert_response :success
  end

  test "should get edit" do
    get edit_racer_entry_url(@racer_entry)
    assert_response :success
  end

  test "should update racer_entry" do
    patch racer_entry_url(@racer_entry), params: { racer_entry: { best_lap: @racer_entry.best_lap, car: @racer_entry.car, cheating: @racer_entry.cheating, finished: @racer_entry.finished, name: @racer_entry.name, team: @racer_entry.team } }
    assert_redirected_to racer_entry_url(@racer_entry)
  end

  test "should destroy racer_entry" do
    assert_difference('RacerEntry.count', -1) do
      delete racer_entry_url(@racer_entry)
    end

    assert_redirected_to racer_entries_url
  end
end
