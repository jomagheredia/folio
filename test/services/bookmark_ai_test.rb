require "test_helper"

class BookmarkAiTest < ActiveSupport::TestCase
  setup do
    @bookmark = bookmarks(:one)
  end

  test "describe returns a draft from the model" do
    stub_openai({ "description" => "A short write-up of the article." })

    result = BookmarkAi.describe(@bookmark)
    assert result.ok
    assert_equal "A short write-up of the article.", result.description
  end

  test "describe includes an image payload for visuals" do
    bookmark = bookmarks(:visual)
    bookmark.image.attach(
      io: File.open(Rails.root.join("test/fixtures/files/test.png"), "rb"),
      filename: "test.png",
      content_type: "image/png"
    )

    seen = nil
    OpenaiClient.fake_chat = lambda { |messages|
      seen = messages
      { "description" => "Concrete and shadow." }
    }

    result = BookmarkAi.describe(bookmark)
    assert result.ok
    content = seen.last[:content]
    assert content.is_a?(Array)
    assert content.any? { |part| part[:type] == "image_url" }
  end

  test "suggest tags returns unused names" do
    stub_openai({ "tags" => [ "recipes", "brutalism", "concrete", "  " ] })

    result = BookmarkAi.suggest_tags(@bookmark)
    assert result.ok
    assert_equal %w[brutalism concrete], result.tags
  end

  test "returns a failure when the client errors" do
    OpenaiClient.fake_chat = ->(_messages) { raise OpenaiClient::Error, "AI isn't available right now." }

    result = BookmarkAi.describe(@bookmark)
    assert_not result.ok
    assert_equal "AI isn't available right now.", result.error
  end

  test "returns a failure when the model omits the description" do
    stub_openai({ "description" => "  " })

    result = BookmarkAi.describe(@bookmark)
    assert_not result.ok
    assert_match(/didn't return a description/, result.error)
  end
end
