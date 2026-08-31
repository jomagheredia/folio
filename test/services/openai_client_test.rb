require "test_helper"

class OpenaiClientTest < ActiveSupport::TestCase
  test "chat uses fake_chat in tests" do
    stub_openai({ "description" => "A draft" })

    result = OpenaiClient.chat(messages: [ { role: "user", content: "hello" } ])
    assert_equal "A draft", result["description"]
  end

  test "chat raises when unconfigured in tests" do
    error = assert_raises(OpenaiClient::Error) do
      OpenaiClient.chat(messages: [ { role: "user", content: "hello" } ])
    end
    assert_equal "AI isn't available right now.", error.message
  end

  test "configured? follows OPENAI_API_KEY" do
    original = ENV["OPENAI_API_KEY"]
    ENV["OPENAI_API_KEY"] = nil
    assert_not OpenaiClient.configured?

    ENV["OPENAI_API_KEY"] = "sk-test"
    assert OpenaiClient.configured?
  ensure
    ENV["OPENAI_API_KEY"] = original
  end

  test "complete parses json and strips fences" do
    fake_client = Object.new
    def fake_client.chat(parameters:)
      { "choices" => [ { "message" => { "content" => "```json\n{\"description\":\"Hi\"}\n```" } } ] }
    end

    OpenAI::Client.stub :new, fake_client do
      result = OpenaiClient.new.complete([ { role: "user", content: "x" } ])
      assert_equal "Hi", result["description"]
    end
  end
end
