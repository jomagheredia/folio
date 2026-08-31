require "test_helper"

class Collections::AiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
    @collection = collections(:spring)
  end

  test "summary returns a json draft" do
    stub_openai({ "summary" => "A quiet set of launch refs." })

    post summary_collection_ai_path(@collection), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body["ok"]
    assert_equal "A quiet set of launch refs.", body["summary"]
  end

  test "empty collection returns an error without 500" do
    collection = @user.collections.create!(name: "Empty set")

    post summary_collection_ai_path(collection), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_not body["ok"]
    assert_match(/Add some bookmarks first/, body["error"])
  end

  test "requires authentication" do
    delete logout_path
    post summary_collection_ai_path(@collection), as: :json
    assert_redirected_to login_path
  end

  test "cannot summarize another user's collection" do
    post summary_collection_ai_path(collections(:other_user)), as: :json
    assert_response :not_found
  end
end
