# frozen_string_literal: true

require "stringio"

class BookmarkImageAttacher
  IMAGE_TYPES = Bookmark::IMAGE_TYPES

  def self.call(bookmark, url)
    new(bookmark, url).call
  end

  def initialize(bookmark, url)
    @bookmark = bookmark
    @url = url.to_s.strip
  end

  def call
    return if @url.blank?

    fetched = SafeHttp.get(@url, max_bytes: Bookmark::MAX_IMAGE_SIZE, timeout: 10)
    content_type = fetched.content_type.to_s.split(";").first.to_s.strip.downcase
    return unless content_type.in?(IMAGE_TYPES)

    filename = File.basename(fetched.uri.path.presence || "image")
    filename = "image#{extension_for(content_type)}" if filename.exclude?(".")

    @bookmark.image.attach(
      io: StringIO.new(fetched.body),
      filename:,
      content_type:
    )
  rescue SafeHttp::Error
    nil
  end

  private
    def extension_for(content_type)
      {
        "image/png" => ".png",
        "image/jpeg" => ".jpg",
        "image/webp" => ".webp",
        "image/gif" => ".gif"
      }.fetch(content_type, ".img")
    end
end
