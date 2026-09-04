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
        bookmark_id: source_bookmark_id,
        defaults: {
          subject: Share.default_subject(bookmarks, collection: collection),
          body: Share.default_body(bookmarks, collection: collection)
        },
        cancel_path: cancel_path_for(collection, bookmarks)
      }
    end

    def share_params
      params.permit(:subject, :note, :body)
    end

    def bookmark_ids_param
      ids = params[:bookmark_ids]
      ids = ids.split(",") if ids.is_a?(String)
      ids = Array(ids).map(&:to_i).reject(&:zero?)
      ids << source_bookmark_id if source_bookmark_id && ids.empty?
      ids.uniq
    end

    def source_bookmark_id
      id = params[:bookmark_id].to_i
      id.positive? ? id : nil
    end

    def cancel_path_for(collection, bookmarks)
      return collection_path(collection) if collection
      return bookmark_path(bookmarks.first) if source_bookmark_id && bookmarks.size == 1

      bookmarks_path
    end

    def after_share_path(share)
      return share.collection if share.collection
      return bookmark_path(source_bookmark_id) if source_bookmark_id && share.bookmark_ids.include?(source_bookmark_id)

      bookmarks_path
    end
end
