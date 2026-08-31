# frozen_string_literal: true

class SharesController < ApplicationController
  include LibrarySerialization

  def new
    collection, bookmarks = load_share_targets

    if bookmarks.empty?
      redirect_back fallback_location: bookmarks_path, alert: "Select at least one bookmark to share."
      return
    end

    render inertia: "shares/New", props: compose_props(collection:, bookmarks:)
  end

  def create
    collection = Current.user.collections.find_by(id: params[:collection_id]) if params[:collection_id].present?
    bookmarks = Current.user.bookmarks.where(id: bookmark_ids_param)

    share = Current.user.shares.new(share_params)
    share.collection = collection
    share.bookmarks = bookmarks
    share.recipients = Share.parse_recipients(params[:recipients])
    share.sent_at = Time.current

    if share.save
      share.deliver_to_recipients
      redirect_to after_share_path(share), notice: "Sent to #{share.recipients.to_sentence}."
    else
      redirect_back fallback_location: new_share_path, inertia: inertia_record_errors(share)
    end
  end

  private
    def load_share_targets
      collection = Current.user.collections.find_by(id: params[:collection_id]) if params[:collection_id].present?
      bookmarks = if collection
        collection.bookmarks.includes(:tags, :collections, image_attachment: :blob).newest_first
      else
        ids = bookmark_ids_param
        Current.user.bookmarks.includes(:tags, :collections, image_attachment: :blob).where(id: ids)
          .sort_by { |bookmark| ids.index(bookmark.id) || 0 }
      end

      [ collection, Array(bookmarks) ]
    end

    def compose_props(collection:, bookmarks:)
      {
        collection: collection && { id: collection.id, name: collection.name, ai_summary: collection.ai_summary },
        bookmarks: bookmarks.map { |bookmark| bookmark_card_props(bookmark) },
        defaults: {
          subject: Share.default_subject(bookmarks, collection: collection),
          body: Share.default_body(bookmarks, collection: collection)
        },
        cancel_path: collection ? collection_path(collection) : bookmarks_path
      }
    end

    def share_params
      params.permit(:subject, :note, :body)
    end

    def bookmark_ids_param
      ids = params[:bookmark_ids]
      ids = ids.split(",") if ids.is_a?(String)
      Array(ids).map(&:to_i).reject(&:zero?).uniq
    end

    def after_share_path(share)
      share.collection || bookmarks_path
    end
end
