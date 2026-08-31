require "application_system_test_case"

class ShareSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "signed-in user can email a collection and see send history" do
    log_in_through_ui

    visit collection_path(collections(:spring))
    assert_text "Spring campaign refs"
    click_on "Share"

    wait_for_share_form "Share Spring campaign refs"
    fill_in_react "Recipients", with: "colleague@example.com"
    fill_in_react "Note", with: "For the launch review"
    find("[data-testid='send-share']").click

    assert_text "Sent to colleague@example.com", wait: 10
    assert_text "colleague@example.com"
  end

  test "signed-in user can share a selected library bookmark" do
    log_in_through_ui

    find("input[aria-label='Select Example Article']").click
    click_on "Share selected"

    wait_for_share_form "Share finds"
    fill_in_react "Recipients", with: "friend@example.com"
    fill_in_react "Note", with: "A few finds"
    find("[data-testid='send-share']").click

    assert_text "Sent to friend@example.com", wait: 10
    assert_current_path bookmarks_path
  end

  private
    def log_in_through_ui
      visit login_path
      fill_in "Email", with: @user.email
      fill_in "Password", with: "password"
      click_on "Log in"
      assert_text "Library"
    end

    def wait_for_share_form(heading)
      assert_text heading
      assert_selector "#recipients"
      assert_selector "[data-testid='send-share']:not([disabled])"
    end
end
