require "application_system_test_case"

class MatchesTest < ApplicationSystemTestCase
  setup do
    @match = matches(:one)
  end

  test "visiting the index" do
    visit matches_url
    assert_selector "h1", text: "Matches"
  end

  test "should create match" do
    visit matches_url
    click_on "New match"

    fill_in "Black player", with: @match.black_player_id
    fill_in "Played at", with: @match.played_at
    fill_in "Status", with: @match.status
    fill_in "White player", with: @match.white_player_id
    click_on "Create Match"

    assert_text "Match was successfully created"
    click_on "Back"
  end

  test "should update Match" do
    visit match_url(@match)
    click_on "Edit this match", match: :first

    fill_in "Black player", with: @match.black_player_id
    fill_in "Played at", with: @match.played_at.to_s
    fill_in "Status", with: @match.status
    fill_in "White player", with: @match.white_player_id
    click_on "Update Match"

    assert_text "Match was successfully updated"
    click_on "Back"
  end

  test "should destroy Match" do
    visit match_url(@match)
    click_on "Destroy this match", match: :first

    assert_text "Match was successfully destroyed"
  end
end
