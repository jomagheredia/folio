# frozen_string_literal: true

class CollectionAi
  Result = Struct.new(:ok, :error, :summary, keyword_init: true)

  def self.summarize(collection)
    new(collection).summarize
  end

  def initialize(collection)
    @collection = collection
  end

  def summarize
    bookmarks = @collection.bookmarks.includes(:tags).newest_first.to_a
    return failure("Add some bookmarks first, then summarize.") if bookmarks.empty?

    payload = OpenaiClient.chat(messages: [
      { role: "system", content: system_prompt },
      { role: "user", content: user_prompt(bookmarks) }
    ])
    text = payload["summary"].to_s.strip
    return failure("AI didn't return a summary.") if text.blank?

    Result.new(ok: true, error: nil, summary: text)
  rescue OpenaiClient::Error => e
    failure(e.message)
  end

  private
    def failure(message)
      Result.new(ok: false, error: message, summary: nil)
    end

    def system_prompt
      "You write a short overview of a curated collection of bookmarks. " \
        "Return JSON: {\"summary\": \"...\"}. Write 2–4 sentences in plain language " \
        "for the owner and for a share email. Don't invent items that aren't listed."
    end

    def user_prompt(bookmarks)
      notes = @collection.notes.to_s.strip
      items = bookmarks.map { |bookmark| item_line(bookmark) }.join("\n")

      <<~TEXT
        Summarize this collection.

        Name: #{@collection.name}
        Notes: #{notes.presence || "(none)"}
        Items:
        #{items}
      TEXT
    end

    def item_line(bookmark)
      parts = [ "- #{bookmark.title} (#{bookmark.kind})" ]
      parts << bookmark.url if bookmark.url.present?
      snippet = bookmark.description.to_s.strip
      parts << snippet if snippet.present?
      tag_names = bookmark.tags.map(&:name)
      parts << "tags: #{tag_names.join(", ")}" if tag_names.any?
      parts.join(" — ")
    end
end
