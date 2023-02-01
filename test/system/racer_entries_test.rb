require "application_system_test_case"

class RacerEntriesTest < ApplicationSystemTestCase
  setup do
    @racer_entry = racer_entries(:one)
  end

  test "visiting the index" do
    visit racer_entries_url
    assert_selector "h1", text: "Racer Entries"
  end

  test "creating a Racer entry" do
    visit racer_entries_url
    click_on "New Racer Entry"

    fill_in "Best lap", with: @racer_entry.best_lap
    fill_in "Car", with: @racer_entry.car
    check "Cheating" if @racer_entry.cheating
    check "Finished" if @racer_entry.finished
    fill_in "Name", with: @racer_entry.name
    fill_in "Team", with: @racer_entry.team
    click_on "Create Racer entry"

    assert_text "Racer entry was successfully created"
    click_on "Back"
  end

  test "updating a Racer entry" do
    visit racer_entries_url
    click_on "Edit", match: :first

    fill_in "Best lap", with: @racer_entry.best_lap
    fill_in "Car", with: @racer_entry.car
    check "Cheating" if @racer_entry.cheating
    check "Finished" if @racer_entry.finished
    fill_in "Name", with: @racer_entry.name
    fill_in "Team", with: @racer_entry.team
    click_on "Update Racer entry"

    assert_text "Racer entry was successfully updated"
    click_on "Back"
  end

  test "destroying a Racer entry" do
    visit racer_entries_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Racer entry was successfully destroyed"
  end
end
