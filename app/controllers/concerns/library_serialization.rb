# frozen_string_literal: true

module LibrarySerialization
  extend ActiveSupport::Concern

  private
    def bookmark_card_props(bookmark)
      {
        id: bookmark.id,
        kind: bookmark.kind,
        title: bookmark.title,
        url: bookmark.url,
        description: bookmark.description,
        image_url: bookmark_image_url(bookmark),
        tags: bookmark.tags.sort_by { |tag| tag.name.downcase }.map { |tag| tag_props(tag) },
        collections: bookmark.collections.sort_by { |collection| collection.name.downcase }.map { |collection| { id: collection.id, name: collection.name } },
        created_at: bookmark.created_at.iso8601
      }
    end

    def bookmark_image_url(bookmark)
      return unless bookmark.image.attached?

      rails_blob_path(bookmark.image, only_path: true)
    end

    def tag_props(tag, bookmarks_count: nil)
      props = { id: tag.id, name: tag.name }
      props[:bookmarks_count] = bookmarks_count.to_i unless bookmarks_count.nil?
      props
    end

    def collection_props(collection, bookmarks_count: nil)
      props = { id: collection.id, name: collection.name, notes: collection.notes, ai_summary: collection.ai_summary }
      props[:bookmarks_count] = bookmarks_count.to_i unless bookmarks_count.nil?
      props
    end

    def share_history_props(share)
      {
        id: share.id,
        recipients: share.recipients,
        subject: share.subject,
        sent_at: share.sent_at&.iso8601,
        sent_at_label: share.sent_at&.to_fs(:long)
      }
    end

    def tag_options
      Current.user.tags.order(:name).map { |tag| { id: tag.id, name: tag.name } }
    end

    def collection_options
      Current.user.collections.order(:name).map { |collection| { id: collection.id, name: collection.name } }
    end

    def inertia_record_errors(record)
      { errors: record.errors.to_hash(true).transform_values(&:first) }
    end
end
