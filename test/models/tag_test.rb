require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "name is unique per user case-insensitively" do
    tag = users(:one).tags.new(name: "RECIPES")
    assert_not tag.valid?
    assert_includes tag.errors[:name], "has already been taken"
  end

  test "two users can share a tag name" do
    tag = users(:two).tags.new(name: "brutalism")
    assert tag.valid?
  end

  test "strips name" do
    tag = users(:one).tags.create!(name: "  mood  ")
    assert_equal "mood", tag.name
  end

  test "destroying a tag does not delete bookmarks" do
    tag = tags(:recipes)
    bookmark = bookmarks(:one)

    assert_difference -> { Tag.count }, -1 do
      assert_no_difference -> { Bookmark.count } do
        tag.destroy
      end
    end

    assert Bookmark.exists?(bookmark.id)
  end
end
