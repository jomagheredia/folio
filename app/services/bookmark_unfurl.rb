# frozen_string_literal: true

class BookmarkUnfurl
  Result = Struct.new(
    :ok, :error, :title, :description, :image_url, :content_type, :duplicate, :existing,
    keyword_init: true
  )

  def self.call(url:, user:)
    new(url:, user:).call
  end

  def initialize(url:, user:)
    @url = url.to_s.strip
    @user = user
  end

  def call
    return failure("Enter a URL to fetch a preview.") if @url.blank?

    fetched = SafeHttp.get(@url)
    existing = existing_bookmark(fetched.uri.to_s)

    if image_response?(fetched)
      return success(
        title: File.basename(fetched.uri.path.presence || "image"),
        description: nil,
        image_url: fetched.uri.to_s,
        content_type: fetched.content_type,
        existing:
      )
    end

    title, description, image_url = parse_html(fetched.body, fetched.uri)
    success(title:, description:, image_url:, content_type: fetched.content_type, existing:)
  rescue SafeHttp::Error => e
    failure("Couldn't reach that page (#{e.message}). You can still save the URL.")
  end

  private
    def failure(message)
      Result.new(ok: false, error: message, duplicate: false, existing: nil)
    end

    def success(title:, description:, image_url:, content_type:, existing:)
      Result.new(
        ok: true,
        error: nil,
        title:,
        description:,
        image_url:,
        content_type:,
        duplicate: existing.present?,
        existing:
      )
    end

    def existing_bookmark(resolved_url)
      bookmark = @user.bookmarks.where(url: [ @url, resolved_url ].uniq).newest_first.first
      return nil unless bookmark

      { id: bookmark.id, title: bookmark.title }
    end

    def image_response?(fetched)
      fetched.content_type.to_s.downcase.start_with?("image/")
    end

    def parse_html(body, uri)
      doc = Nokogiri::HTML(body)
      title = meta_content(doc, "og:title").presence || doc.at("title")&.text&.squish
      description = meta_content(doc, "og:description").presence ||
                    doc.at('meta[name="description"]')&.[]("content")&.squish
      image_url = absolute_url(meta_content(doc, "og:image"), uri)
      [ title, description, image_url ]
    end

    def meta_content(doc, property)
      doc.at("meta[property='#{property}']")&.[]("content")&.squish
    end

    def absolute_url(value, base)
      return if value.blank?

      URI.join(base, value).to_s
    rescue URI::InvalidURIError
      nil
    end
end
