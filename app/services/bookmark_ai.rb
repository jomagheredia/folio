# frozen_string_literal: true

require "base64"

class BookmarkAi
  Result = Struct.new(:ok, :error, :description, :tags, :summary, keyword_init: true)
  TAG_LIMIT = 8
  EXISTING_TAG_LIMIT = 50

  def self.describe(bookmark)
    new(bookmark).describe
  end

  def self.suggest_tags(bookmark)
    new(bookmark).suggest_tags
  end

  def self.summarize(bookmark)
    new(bookmark).summarize
  end

  def initialize(bookmark)
    @bookmark = bookmark
  end

  def describe
    payload = OpenaiClient.chat(messages: describe_messages)
    text = payload["description"].to_s.strip
    return failure("AI didn't return a description.") if text.blank?

    Result.new(ok: true, error: nil, description: text)
  rescue OpenaiClient::Error => e
    failure(e.message)
  end

  def suggest_tags
    payload = OpenaiClient.chat(messages: tag_messages)
    names = Array(payload["tags"]).map { |name| name.to_s.strip }.reject(&:blank?)
    names.uniq! { |name| name.downcase }
    names.reject! { |name| already_tagged?(name) }
    names = names.first(TAG_LIMIT)
    return failure("AI didn't return any tags.") if names.empty?

    Result.new(ok: true, error: nil, tags: names)
  rescue OpenaiClient::Error => e
    failure(e.message)
  end

  def summarize
    payload = OpenaiClient.chat(messages: summarize_messages)
    text = payload["summary"].to_s.strip
    return failure("AI didn't return a summary.") if text.blank?

    Result.new(ok: true, error: nil, summary: text)
  rescue OpenaiClient::Error => e
    failure(e.message)
  end

  private
    def failure(message)
      Result.new(ok: false, error: message, description: nil, tags: nil, summary: nil)
    end

    def describe_messages
      [
        { role: "system", content: describe_system_prompt },
        user_message(describe_prompt)
      ]
    end

    def tag_messages
      [
        { role: "system", content: tag_system_prompt },
        user_message(tag_prompt)
      ]
    end

    def summarize_messages
      [
        { role: "system", content: summarize_system_prompt },
        user_message(summarize_prompt)
      ]
    end

    def user_message(text)
      image = image_data_url
      if image
        {
          role: "user",
          content: [
            { type: "text", text: text },
            { type: "image_url", image_url: { url: image } }
          ]
        }
      else
        { role: "user", content: text }
      end
    end

    def describe_system_prompt
      "You help someone describe a saved bookmark in their personal library. " \
        "Return JSON: {\"description\": \"...\"}. Write 1–3 plain sentences. " \
        "No hashtags. Do not invent facts that are not implied by the title, snippet, URL, or image."
    end

    def tag_system_prompt
      "You suggest short theme tags for a saved bookmark. " \
        "Return JSON: {\"tags\": [\"tag one\", \"tag two\"]}. " \
        "Give 5 to 8 tags. Prefer the person's existing tags when they fit. " \
        "Tags should be lowercase, 1–3 words, with no hashtags."
    end

    def summarize_system_prompt
      "You write a short overview of a saved bookmark in a personal library. " \
        "Return JSON: {\"summary\": \"...\"}. Write 1–2 plain sentences. " \
        "No hashtags. Do not invent facts that are not implied by the title, snippet, URL, or image."
    end

    def describe_prompt
      if @bookmark.visual?
        <<~TEXT
          Describe this visual reference so the owner can find it later.

          #{bookmark_context}
        TEXT
      else
        <<~TEXT
          Describe this saved link so the owner can remember why they kept it.

          #{bookmark_context}
        TEXT
      end
    end

    def tag_prompt
      existing = @bookmark.user.tags.order(:name).limit(EXISTING_TAG_LIMIT).pluck(:name)
      current = @bookmark.tags.map(&:name)

      <<~TEXT
        Suggest tags for this bookmark.

        #{bookmark_context}
        Existing tags in this library: #{existing.join(", ").presence || "(none yet)"}
        Tags already on this bookmark: #{current.join(", ").presence || "(none)"}
      TEXT
    end

    def summarize_prompt
      if @bookmark.visual?
        <<~TEXT
          Write a short summary of this visual reference.

          #{bookmark_context}
        TEXT
      else
        <<~TEXT
          Write a short summary of this saved link.

          #{bookmark_context}
        TEXT
      end
    end

    def bookmark_context
      lines = [ "Title: #{@bookmark.title}" ]
      lines << "Type: #{@bookmark.kind}"
      lines << "URL: #{@bookmark.url}" if @bookmark.url.present?
      snippet = @bookmark.description.to_s.strip
      lines << "Snippet: #{snippet}" if snippet.present?
      lines.join("\n")
    end

    def already_tagged?(name)
      @bookmark.tags.any? { |tag| tag.name.downcase == name.downcase }
    end

    def image_data_url
      return unless @bookmark.image.attached?

      blob = @bookmark.image.blob
      return if blob.byte_size > OpenaiClient::MAX_IMAGE_BYTES

      content_type = blob.content_type.presence || "image/jpeg"
      data = @bookmark.image.download
      "data:#{content_type};base64,#{Base64.strict_encode64(data)}"
    end
end
