require "application_system_test_case"

class ShareSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "signed-in user can email a collection and see send history" do
    log_in_through_ui

    visit collection_path(collections(:spring))
    assert_text "Spring campaign refs"
    js_click("[data-testid='share-collection']")

    assert_text "Share Spring campaign refs", wait: 10
    fill_react_field("recipients", "colleague@example.com")
    fill_react_field("note", "For the launch review")
    js_click("[data-testid='send-share']")

    assert_text "Sent to colleague@example.com", wait: 10
    assert_text "colleague@example.com"
  end

  test "signed-in user can share a selected library bookmark" do
    log_in_through_ui

    find("input[aria-label='Select Example Article']").click
    js_click('a[href^="/shares/new"]')

    assert_text "Share finds", wait: 10
    fill_react_field("recipients", "friend@example.com")
    fill_react_field("note", "A few finds")
    assert_field "Recipients", with: "friend@example.com"
    js_click("[data-testid='send-share']")

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
end
