require "application_system_test_case"

class ProfilesTest < ApplicationSystemTestCase
  setup do
    @profile = profiles(:one)
  end

  test "visiting the index" do
    visit profiles_url
    assert_selector "h1", text: "Profiles"
  end

  test "creating a Profile" do
    visit profiles_url
    click_on "New Profile"

    fill_in "About", with: @profile.about
    fill_in "Crowdin", with: @profile.crowdin
    fill_in "Discord", with: @profile.discord
    fill_in "Gender", with: @profile.gender
    fill_in "Github", with: @profile.github
    fill_in "Instagram", with: @profile.instagram
    fill_in "Interests", with: @profile.interests
    fill_in "Location", with: @profile.location
    fill_in "Occupation", with: @profile.occupation
    fill_in "Public email", with: @profile.public_email
    fill_in "Steam", with: @profile.steam
    fill_in "Twitter", with: @profile.twitter
    click_on "Create Profile"

    assert_text "Profile was successfully created"
    click_on "Back"
  end

  test "updating a Profile" do
    visit profiles_url
    click_on "Edit", match: :first

    fill_in "About", with: @profile.about
    fill_in "Crowdin", with: @profile.crowdin
    fill_in "Discord", with: @profile.discord
    fill_in "Gender", with: @profile.gender
    fill_in "Github", with: @profile.github
    fill_in "Instagram", with: @profile.instagram
    fill_in "Interests", with: @profile.interests
    fill_in "Location", with: @profile.location
    fill_in "Occupation", with: @profile.occupation
    fill_in "Public email", with: @profile.public_email
    fill_in "Steam", with: @profile.steam
    fill_in "Twitter", with: @profile.twitter
    click_on "Update Profile"

    assert_text "Profile was successfully updated"
    click_on "Back"
  end

  test "destroying a Profile" do
    visit profiles_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Profile was successfully destroyed"
  end
end
