require "application_system_test_case"

class LibrarySystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "signed-in user can save a link file it and search" do
    visit login_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password"
    click_on "Log in"

    assert_text "Library"

    click_on "Save a link"
    assert_text "Folio fills in a title"

    fill_react_field("url", "https://example.com/system-test")
    fill_react_field("title", "System test find")
    js_click("[data-testid='save-bookmark']")

    assert_text "Saved to your library", wait: 10
    assert_text "System test find"
    assert_text "https://example.com/system-test"

    visit collections_path
    click_on "New collection"
    fill_react_field("name", "Kitchen refs")
    js_click("form button[type='submit']")
    assert_text "Kitchen refs"

    visit bookmarks_path
    fill_in "library-search", with: "System test"
    click_on "Search"
    assert_text "System test find"
  end
end
