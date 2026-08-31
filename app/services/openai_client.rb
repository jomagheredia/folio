# frozen_string_literal: true

require "openai"

# Thin wrapper around the OpenAI chat API. Tests set `fake_chat` so nothing
# hits the network; production uses OPENAI_API_KEY.
class OpenaiClient
  class Error < StandardError; end

  TIMEOUT = 20
  MAX_IMAGE_BYTES = 4.megabytes

  class << self
    attr_accessor :fake_chat
  end

  def self.api_key
    ENV["OPENAI_API_KEY"].presence
  end

  def self.model
    ENV.fetch("OPENAI_MODEL", "gpt-4o-mini")
  end

  def self.configured?
    api_key.present?
  end

  def self.chat(messages:)
    if fake_chat
      return fake_chat.call(messages)
    end

    raise Error, "AI isn't available right now." if Rails.env.test? || !configured?

    new.complete(messages)
  end

  def complete(messages)
    response = client.chat(parameters: {
      model: self.class.model,
      messages: messages,
      response_format: { type: "json_object" }
    })
    content = response.dig("choices", 0, "message", "content")
    raise Error, "AI returned an empty response." if content.blank?

    parse_json(content)
  rescue Error
    raise
  rescue Faraday::TimeoutError, Faraday::ConnectionFailed, Net::OpenTimeout, Net::ReadTimeout
    raise Error, "AI is taking too long. Try again, or write it yourself."
  rescue JSON::ParserError
    raise Error, "AI returned something we couldn't read."
  rescue Faraday::Error, OpenAI::Error
    raise Error, "AI isn't available right now."
  end

  private
    def client
      @client ||= OpenAI::Client.new(access_token: self.class.api_key, request_timeout: TIMEOUT)
    end

    def parse_json(content)
      cleaned = content.to_s.strip
      cleaned = cleaned.sub(/\A```(?:json)?\s*/i, "").sub(/\s*```\z/, "")
      JSON.parse(cleaned)
    end
end
