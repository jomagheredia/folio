require "test_helper"

class Bookmarks::PreviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    log_in_as(users(:one))
  end

  test "returns preview json and duplicate info" do
    fetched = SafeHttp::Result.new(
      body: "<html><head><title>Example Article</title></head></html>",
      content_type: "text/html",
      uri: URI.parse("https://example.com/article")
    )

    SafeHttp.stub :get, fetched do
      post preview_bookmarks_path, params: { url: "https://example.com/article" }, as: :json
    end

    assert_response :success
    body = JSON.parse(response.body)
    assert body["ok"]
    assert body["duplicate"]
    assert_equal bookmarks(:one).id, body["existing"]["id"]
    assert_equal bookmark_path(bookmarks(:one)), body["existing"]["path"]
  end

  test "requires authentication" do
    delete logout_path
    post preview_bookmarks_path, params: { url: "https://example.com" }, as: :json
    assert_redirected_to login_path
  end
end
