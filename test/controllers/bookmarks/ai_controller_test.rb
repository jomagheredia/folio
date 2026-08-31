require "test_helper"

class Bookmarks::AiControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    log_in_as(@user)
    @bookmark = bookmarks(:one)
  end

  test "description returns a json draft" do
    stub_openai({ "description" => "A draft about design systems." })

    post description_bookmark_ai_path(@bookmark), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body["ok"]
    assert_equal "A draft about design systems.", body["description"]
  end

  test "tags returns a json list" do
    stub_openai({ "tags" => [ "brutalism", "concrete" ] })

    post tags_bookmark_ai_path(@bookmark), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert body["ok"]
    assert_equal %w[brutalism concrete], body["tags"]
  end

  test "description failure payload does not 500" do
    OpenaiClient.fake_chat = ->(_messages) { raise OpenaiClient::Error, "AI isn't available right now." }

    post description_bookmark_ai_path(@bookmark), as: :json
    assert_response :success
    body = JSON.parse(response.body)
    assert_not body["ok"]
    assert_equal "AI isn't available right now.", body["error"]
  end

  test "requires authentication" do
    delete logout_path
    post description_bookmark_ai_path(@bookmark), as: :json
    assert_redirected_to login_path
  end

  test "cannot describe another user's bookmark" do
    post description_bookmark_ai_path(bookmarks(:other_user)), as: :json
    assert_response :not_found
  end
end
