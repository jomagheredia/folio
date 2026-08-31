require "test_helper"

class CollectionAiTest < ActiveSupport::TestCase
  test "summarize returns a draft from the model" do
    stub_openai({ "summary" => "A quiet set of launch refs." })

    result = CollectionAi.summarize(collections(:spring))
    assert result.ok
    assert_equal "A quiet set of launch refs.", result.summary
  end

  test "does not call the model when the collection is empty" do
    collection = users(:one).collections.create!(name: "Empty set")
    called = false
    OpenaiClient.fake_chat = ->(_messages) {
      called = true
      { "summary" => "Should not run" }
    }

    result = CollectionAi.summarize(collection)
    assert_not result.ok
    assert_match(/Add some bookmarks first/, result.error)
    assert_not called
  end

  test "returns a failure when the client errors" do
    OpenaiClient.fake_chat = ->(_messages) { raise OpenaiClient::Error, "AI is taking too long. Try again, or write it yourself." }

    result = CollectionAi.summarize(collections(:spring))
    assert_not result.ok
    assert_match(/taking too long/, result.error)
  end
end
