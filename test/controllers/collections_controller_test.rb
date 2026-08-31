require "test_helper"

class CollectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
  end

  test "show includes past share history" do
    get collection_path(collections(:spring))
    assert_response :success
    assert_includes response.body, "friend@example.com"
    assert_includes response.body, "Spring campaign refs"
  end

  test "creates a collection" do
    assert_difference -> { @user.collections.count }, 1 do
      post collections_path, params: { name: "Moods", notes: "Quiet" }
    end

    collection = @user.collections.order(:created_at).last
    assert_redirected_to collection_path(collection)
    assert_equal "Moods", collection.name
  end

  test "cannot show another user's collection" do
    get collection_path(collections(:other_user))
    assert_response :not_found
  end

  test "updates name and notes" do
    collection = collections(:spring)
    patch collection_path(collection), params: { name: "Spring v2", notes: "Updated" }
    assert_redirected_to collection_path(collection)
    collection.reload
    assert_equal "Spring v2", collection.name
    assert_equal "Updated", collection.notes
  end

  test "updates ai_summary" do
    collection = collections(:spring)
    patch collection_path(collection), params: { ai_summary: "A quiet set of launch refs." }
    assert_redirected_to collection_path(collection)
    assert_equal "A quiet set of launch refs.", collection.reload.ai_summary
  end

  test "adds and removes a bookmark" do
    collection = collections(:spring)
    bookmark = bookmarks(:visual)

    post add_bookmark_collection_path(collection), params: { bookmark_id: bookmark.id }
    assert_redirected_to collection_path(collection)
    assert_includes collection.reload.bookmarks, bookmark

    delete remove_bookmark_collection_path(collection), params: { bookmark_id: bookmark.id }
    assert_redirected_to collection_path(collection)
    assert_not_includes collection.reload.bookmarks, bookmark
    assert Bookmark.exists?(bookmark.id)
  end

  test "cannot add another user's bookmark" do
    post add_bookmark_collection_path(collections(:spring)), params: { bookmark_id: bookmarks(:other_user).id }
    assert_response :not_found
  end

  test "destroying a collection keeps bookmarks" do
    collection = collections(:spring)
    assert_difference -> { Collection.count }, -1 do
      assert_no_difference -> { Bookmark.count } do
        delete collection_path(collection)
      end
    end
    assert_redirected_to collections_path
  end
end
