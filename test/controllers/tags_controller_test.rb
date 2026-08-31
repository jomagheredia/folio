require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
  end

  test "index is successful" do
    get tags_path
    assert_response :success
  end

  test "show lists tagged bookmarks" do
    get tag_path(tags(:recipes))
    assert_response :success
  end

  test "cannot show another user's tag" do
    get tag_path(tags(:other_user))
    assert_response :not_found
  end

  test "renames a tag" do
    tag = tags(:recipes)
    patch tag_path(tag), params: { name: "cookery" }
    assert_redirected_to tag_path(tag)
    assert_equal "cookery", tag.reload.name
  end

  test "destroying a tag keeps bookmarks" do
    tag = tags(:recipes)
    assert_difference -> { Tag.count }, -1 do
      assert_no_difference -> { Bookmark.count } do
        delete tag_path(tag)
      end
    end
    assert_redirected_to tags_path
  end
end
