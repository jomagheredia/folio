require "application_system_test_case"

class AiAssistSystemTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "signed-in user can describe suggest tags summarize and include the summary when sharing" do
    log_in_through_ui

    stub_openai({ "description" => "A draft about design systems." })
    visit bookmark_path(bookmarks(:one))
    js_click("[data-testid='describe-with-ai']")
    assert_field "ai-description-draft", with: "A draft about design systems.", wait: 10
    fill_react_field("ai-description-draft", "Edited draft about design systems.")
    js_click("[data-testid='keep-description']")
    assert_text "Edited draft about design systems.", wait: 10

    stub_openai({ "tags" => [ "brutalism", "concrete" ] })
    js_click("[data-testid='suggest-tags']")
    assert_text "Suggested tags — tap to add, or ignore.", wait: 10
    js_click("[data-testid='suggested-tag-concrete']")
    assert_selector "a", text: "concrete", wait: 10

    stub_openai({ "summary" => "A quiet set of launch refs." })
    visit collection_path(collections(:spring))
    assert_field "ai-summary-draft", with: "A quiet set of launch refs.", wait: 10
    js_click("[data-testid='keep-summary']")
    assert_selector "[data-testid='collection-ai-summary']", text: "A quiet set of launch refs.", wait: 10

    js_click("[data-testid='share-collection']")
    assert_text "Share Spring campaign refs", wait: 10
    assert_includes find("#body").value, "A quiet set of launch refs."
  end

  test "hand filing still works when AI is unavailable" do
    log_in_through_ui
    visit bookmark_path(bookmarks(:one))

    js_click("[data-testid='describe-with-ai']")
    assert_text "AI isn't available right now.", wait: 10

    js_click("[data-testid='edit-bookmark']")
    assert_text "Update the title, description, tags, and collections.", wait: 10
    fill_react_field("description", "Notes I wrote myself")
    js_click("[data-testid='save-bookmark']")
    assert_text "Notes I wrote myself", wait: 10
  end

  test "saving a bookmark auto-drafts a summary to keep" do
    log_in_through_ui
    stub_openai({ "summary" => "A short overview of the find." })

    click_on "Save a link"
    fill_react_field("url", "https://example.com/auto-summary")
    fill_react_field("title", "Auto summary find")
    js_click("[data-testid='save-bookmark']")

    assert_field "ai-bookmark-summary-draft", with: "A short overview of the find.", wait: 10
    fill_react_field("ai-bookmark-summary-draft", "Edited overview of the find.")
    js_click("[data-testid='keep-bookmark-summary']")
    assert_selector "[data-testid='bookmark-summary']", text: "Edited overview of the find.", wait: 10
  end

  test "opening a collection without a summary auto-drafts one" do
    log_in_through_ui
    stub_openai({ "summary" => "A quiet set of launch refs." })

    visit collection_path(collections(:spring))
    assert_field "ai-summary-draft", with: "A quiet set of launch refs.", wait: 10
    assert_no_selector "[data-testid='collection-ai-summary']"
  end

  test "automatic drafts do not overwrite saved summaries" do
    log_in_through_ui
    bookmarks(:one).update!(summary: "Hand-written bookmark overview")
    collections(:spring).update!(ai_summary: "Hand-written collection overview")
    stub_openai({ "summary" => "Should not replace saved words." })

    visit bookmark_path(bookmarks(:one), auto_summary: 1)
    assert_selector "[data-testid='bookmark-summary']", text: "Hand-written bookmark overview"
    assert_no_field "ai-bookmark-summary-draft"
    assert_no_text "Should not replace saved words."

    visit collection_path(collections(:spring))
    assert_selector "[data-testid='collection-ai-summary']", text: "Hand-written collection overview"
    assert_no_field "ai-summary-draft"
    assert_no_text "Should not replace saved words."
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
