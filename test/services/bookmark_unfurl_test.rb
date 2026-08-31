require "test_helper"

class BookmarkUnfurlTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
  end

  test "parses open graph tags" do
    html = <<~HTML
      <html>
        <head>
          <title>Fallback</title>
          <meta property="og:title" content="OG Title">
          <meta property="og:description" content="A snippet">
          <meta property="og:image" content="/cover.png">
        </head>
      </html>
    HTML
    fetched = SafeHttp::Result.new(
      body: html,
      content_type: "text/html",
      uri: URI.parse("https://example.com/page")
    )

    SafeHttp.stub :get, fetched do
      result = BookmarkUnfurl.call(url: "https://example.com/page", user: @user)
      assert result.ok
      assert_equal "OG Title", result.title
      assert_equal "A snippet", result.description
      assert_equal "https://example.com/cover.png", result.image_url
      assert_not result.duplicate
    end
  end

  test "falls back to title and meta description" do
    html = <<~HTML
      <html>
        <head>
          <title>  Page Title  </title>
          <meta name="description" content="Meta description">
        </head>
      </html>
    HTML
    fetched = SafeHttp::Result.new(
      body: html,
      content_type: "text/html; charset=utf-8",
      uri: URI.parse("https://example.com/page")
    )

    SafeHttp.stub :get, fetched do
      result = BookmarkUnfurl.call(url: "https://example.com/page", user: @user)
      assert result.ok
      assert_equal "Page Title", result.title
      assert_equal "Meta description", result.description
    end
  end

  test "flags a duplicate url already in the library" do
    fetched = SafeHttp::Result.new(
      body: "<html><head><title>Example Article</title></head></html>",
      content_type: "text/html",
      uri: URI.parse("https://example.com/article")
    )

    SafeHttp.stub :get, fetched do
      result = BookmarkUnfurl.call(url: "https://example.com/article", user: @user)
      assert result.ok
      assert result.duplicate
      assert_equal bookmarks(:one).id, result.existing[:id]
    end
  end

  test "returns a failure result when fetch errors" do
    failing = ->(*_args, **_kwargs) { raise SafeHttp::Error, "timed out" }

    SafeHttp.stub :get, failing do
      result = BookmarkUnfurl.call(url: "https://example.com/down", user: @user)
      assert_not result.ok
      assert_match(/Couldn't reach that page/, result.error)
    end
  end
end
