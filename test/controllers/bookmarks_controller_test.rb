require "test_helper"

class BookmarksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @password = "password"
    log_in_as(@user)
  end

  test "unauthenticated users are redirected to login" do
    delete logout_path
    get bookmarks_path
    assert_redirected_to login_path
  end

  test "index lists the current user's bookmarks newest first" do
    get bookmarks_path
    assert_response :success
  end

  test "cannot show another user's bookmark" do
    get bookmark_path(bookmarks(:other_user))
    assert_response :not_found
  end

  test "creates a link bookmark and redirects to show" do
    assert_difference -> { @user.bookmarks.count }, 1 do
      post bookmarks_path, params: {
        kind: "link",
        title: "New find",
        url: "https://example.com/new",
        description: "Notes",
        tag_names: [ "recipes", "fresh" ]
      }
    end

    bookmark = @user.bookmarks.newest_first.first
    assert_redirected_to bookmark_path(bookmark, auto_summary: 1)
    assert_equal "New find", bookmark.title
    assert_equal %w[fresh recipes].sort, bookmark.tags.map(&:name).sort
  end

  test "creates a visual bookmark from an uploaded image" do
    file = fixture_file_upload("test.png", "image/png")

    assert_difference -> { @user.bookmarks.visual.count }, 1 do
      post bookmarks_path, params: {
        kind: "visual",
        title: "Uploaded visual",
        image: file
      }
    end

    bookmark = @user.bookmarks.visual.newest_first.first
    assert_redirected_to bookmark_path(bookmark, auto_summary: 1)
    assert bookmark.image.attached?
  end

  test "create with invalid data redirects back with errors" do
    assert_no_difference -> { Bookmark.count } do
      post bookmarks_path, params: { kind: "link", title: "No URL" }
    end

    assert_response :redirect
  end

  test "updates a bookmark" do
    bookmark = bookmarks(:one)
    patch bookmark_path(bookmark), params: {
      kind: "link",
      title: "Updated title",
      url: bookmark.url,
      description: "Changed",
      tag_names: [ "brutalism" ]
    }

    assert_redirected_to bookmark_path(bookmark)
    bookmark.reload
    assert_equal "Updated title", bookmark.title
    assert_equal [ "brutalism" ], bookmark.tags.map(&:name)
  end

  test "updating only description keeps tags and collections" do
    bookmark = bookmarks(:one)
    assert_includes bookmark.tags.map(&:name), "recipes"
    assert_includes bookmark.collections, collections(:spring)

    patch bookmark_path(bookmark), params: { description: "Kept by AI" }

    assert_redirected_to bookmark_path(bookmark)
    bookmark.reload
    assert_equal "Kept by AI", bookmark.description
    assert_includes bookmark.tags.map(&:name), "recipes"
    assert_includes bookmark.collections, collections(:spring)
  end

  test "updating only summary keeps tags and collections" do
    bookmark = bookmarks(:one)
    assert_includes bookmark.tags.map(&:name), "recipes"
    assert_includes bookmark.collections, collections(:spring)

    patch bookmark_path(bookmark), params: { summary: "A short overview." }

    assert_redirected_to bookmark_path(bookmark)
    bookmark.reload
    assert_equal "A short overview.", bookmark.summary
    assert_includes bookmark.tags.map(&:name), "recipes"
    assert_includes bookmark.collections, collections(:spring)
  end

  test "cannot update another user's bookmark" do
    patch bookmark_path(bookmarks(:other_user)), params: { title: "Hacked" }
    assert_response :not_found
  end

  test "destroys a bookmark and leaves tags" do
    bookmark = bookmarks(:one)

    assert_difference -> { Bookmark.count }, -1 do
      assert_no_difference -> { Tag.count } do
        delete bookmark_path(bookmark)
      end
    end

    assert_redirected_to bookmarks_path
  end

  test "filters by kind tag and search" do
    get bookmarks_path, params: { kind: "link", q: "design", tag_id: tags(:recipes).id }
    assert_response :success
  end
end
