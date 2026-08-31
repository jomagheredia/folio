# frozen_string_literal: true

class CollectionsController < ApplicationController
  include LibrarySerialization

  before_action :set_collection, only: %i[ show edit update destroy add_bookmark remove_bookmark ]

  def index
    collections = Current.user.collections.left_joins(:bookmarks).select("collections.*, COUNT(bookmarks.id) AS bookmarks_count").group("collections.id").order(:name)

    render inertia: "collections/Index", props: {
      collections: collections.map { |collection| collection_props(collection, bookmarks_count: collection.bookmarks_count) }
    }
  end

  def show
    bookmarks = @collection.bookmarks.includes(:tags, :collections, image_attachment: :blob).newest_first
    available = Current.user.bookmarks.where.not(id: bookmarks.select(:id)).newest_first.limit(50)

    render inertia: "collections/Show", props: {
      collection: collection_props(@collection, bookmarks_count: bookmarks.size),
      bookmarks: bookmarks.map { |bookmark| bookmark_card_props(bookmark) },
      available_bookmarks: available.map { |bookmark| { id: bookmark.id, title: bookmark.title, kind: bookmark.kind } },
      shares: @collection.shares.newest_first.map { |share| share_history_props(share) }
    }
  end

  def new
    render inertia: "collections/New", props: {
      collection: { id: nil, name: "", notes: "" }
    }
  end

  def create
    collection = Current.user.collections.new(collection_params)

    if collection.save
      redirect_to collection, notice: "Collection created."
    else
      redirect_back fallback_location: new_collection_path, inertia: inertia_record_errors(collection)
    end
  end

  def edit
    render inertia: "collections/Edit", props: {
      collection: collection_props(@collection)
    }
  end

  def update
    if @collection.update(collection_params)
      redirect_to @collection, notice: "Collection updated."
    else
      redirect_back fallback_location: edit_collection_path(@collection), inertia: inertia_record_errors(@collection)
    end
  end

  def destroy
    @collection.destroy
    redirect_to collections_path, notice: "Collection deleted. Bookmarks are still in your library."
  end

  def add_bookmark
    bookmark = Current.user.bookmarks.find(params[:bookmark_id])
    @collection.bookmarks << bookmark unless @collection.bookmarks.exists?(bookmark.id)
    redirect_to @collection, notice: "Added to collection."
  end

  def remove_bookmark
    bookmark = Current.user.bookmarks.find(params[:bookmark_id])
    @collection.bookmarks.destroy(bookmark)
    redirect_to @collection, notice: "Removed from collection."
  end

  private
    def set_collection
      @collection = Current.user.collections.find(params[:id])
    end

    def collection_params
      params.permit(:name, :notes, :ai_summary)
    end
end
