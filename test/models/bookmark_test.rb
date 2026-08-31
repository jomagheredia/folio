require "test_helper"

class BookmarkTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "link requires a url" do
    bookmark = @user.bookmarks.new(kind: :link, title: "Missing URL")
    assert_not bookmark.valid?
    assert_includes bookmark.errors[:url], "can't be blank"
  end

  test "rejects a non-http url" do
    bookmark = @user.bookmarks.new(kind: :link, title: "FTP", url: "ftp://example.com/file")
    assert_not bookmark.valid?
    assert_includes bookmark.errors[:url], "must be a valid http(s) URL"
  end

  test "visual requires an image" do
    bookmark = @user.bookmarks.new(kind: :visual, title: "No image")
    assert_not bookmark.valid?
    assert_includes bookmark.errors[:image], "can't be blank"
  end

  test "defaults a blank title to Untitled" do
    bookmark = @user.bookmarks.new(kind: :link, title: "  ", url: "https://example.com")
    bookmark.valid?
    assert_equal "Untitled", bookmark.title
  end

  test "assign_tags_from_names creates and reuses tags case-insensitively" do
    bookmark = bookmarks(:one)
    bookmark.assign_tags_from_names([ "Recipes", "brutalism" ])

    assert_equal %w[brutalism recipes].sort, bookmark.tags.map { |tag| tag.name.downcase }.sort
    assert_equal 2, @user.tags.count
  end

  test "search matches title description url and tag names" do
    assert_includes Bookmark.search("design systems"), bookmarks(:one)
    assert_includes Bookmark.search("example.com"), bookmarks(:one)
    assert_includes Bookmark.search("recipes"), bookmarks(:one)
    assert_not_includes Bookmark.search("recipes"), bookmarks(:visual)
    assert_not_includes Bookmark.search("secret"), bookmarks(:one)
  end

  test "newest_first orders by created_at desc" do
    older = bookmarks(:one)
    newer = @user.bookmarks.create!(kind: :link, title: "Newer", url: "https://example.com/newer")
    assert_equal newer, @user.bookmarks.newest_first.first
    assert_includes @user.bookmarks.newest_first, older
  end
end
