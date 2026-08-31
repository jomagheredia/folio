require "test_helper"

class CollectionTest < ActiveSupport::TestCase
  test "requires a name" do
    collection = users(:one).collections.new(name: "")
    assert_not collection.valid?
    assert_includes collection.errors[:name], "can't be blank"
  end

  test "destroying a collection does not delete bookmarks" do
    collection = collections(:spring)
    bookmark = bookmarks(:one)

    assert_difference -> { Collection.count }, -1 do
      assert_no_difference -> { Bookmark.count } do
        collection.destroy
      end
    end

    assert Bookmark.exists?(bookmark.id)
  end

  test "a bookmark can belong to many collections" do
    bookmark = bookmarks(:one)
    extra = users(:one).collections.create!(name: "Second set")
    extra.bookmarks << bookmark

    assert_includes bookmark.collections, collections(:spring)
    assert_includes bookmark.collections, extra
  end
end
