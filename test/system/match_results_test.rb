require "application_system_test_case"

class MatchResultsTest < ApplicationSystemTestCase
  setup do
    @match_result = match_results(:one)
  end

  test "visiting the index" do
    visit match_results_url
    assert_selector "h1", text: "Match results"
  end

  test "should create match result" do
    visit match_results_url
    click_on "New match result"

    check "Draw" if @match_result.draw
    fill_in "Loser", with: @match_result.loser_id
    fill_in "Match", with: @match_result.match_id
    fill_in "Winner", with: @match_result.winner_id
    click_on "Create Match result"

    assert_text "Match result was successfully created"
    click_on "Back"
  end

  test "should update Match result" do
    visit match_result_url(@match_result)
    click_on "Edit this match result", match: :first

    check "Draw" if @match_result.draw
    fill_in "Loser", with: @match_result.loser_id
    fill_in "Match", with: @match_result.match_id
    fill_in "Winner", with: @match_result.winner_id
    click_on "Update Match result"

    assert_text "Match result was successfully updated"
    click_on "Back"
  end

  test "should destroy Match result" do
    visit match_result_url(@match_result)
    click_on "Destroy this match result", match: :first

    assert_text "Match result was successfully destroyed"
  end
end
