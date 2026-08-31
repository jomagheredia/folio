# frozen_string_literal: true

class BookmarksController < ApplicationController
  include LibrarySerialization

  before_action :set_bookmark, only: %i[ show edit update destroy ]

  def index
    bookmarks = Current.user.bookmarks.includes(:tags, :collections, image_attachment: :blob)
    bookmarks = bookmarks.search(params[:q])
    bookmarks = bookmarks.where(kind: params[:kind]) if params[:kind].in?(%w[link visual])
    if params[:tag_id].present?
      tag = Current.user.tags.find_by(id: params[:tag_id])
      bookmarks = tag ? bookmarks.joins(:tags).where(tags: { id: tag.id }) : bookmarks.none
    end
    if params[:collection_id].present?
      collection = Current.user.collections.find_by(id: params[:collection_id])
      bookmarks = collection ? bookmarks.joins(:collections).where(collections: { id: collection.id }) : bookmarks.none
    end

    active_tag = params[:tag_id].present? ? Current.user.tags.find_by(id: params[:tag_id]) : nil
    active_collection = params[:collection_id].present? ? Current.user.collections.find_by(id: params[:collection_id]) : nil

    render inertia: "bookmarks/Index", props: {
      bookmarks: bookmarks.newest_first.map { |bookmark| bookmark_card_props(bookmark) },
      tags: tag_options,
      collections: collection_options,
      filters: {
        q: params[:q].to_s,
        kind: params[:kind].presence_in(%w[link visual]) || "all",
        tag_id: active_tag&.id,
        tag_name: active_tag&.name,
        collection_id: active_collection&.id,
        collection_name: active_collection&.name
      }
    }
  end

  def show
    render inertia: "bookmarks/Show", props: {
      bookmark: bookmark_card_props(@bookmark)
    }
  end

  def new
    render inertia: "bookmarks/New", props: new_edit_props(
      bookmark: {
        id: nil,
        kind: params[:kind].presence_in(%w[link visual]) || "link",
        title: "",
        url: params[:url].to_s,
        description: "",
        image_url: nil,
        tag_names: [],
        collection_ids: Array(params[:collection_id]).map(&:to_i).reject(&:zero?)
      }
    )
  end

  def create
    bookmark = Current.user.bookmarks.new(bookmark_params)
    attach_image(bookmark)

    if bookmark.save
      bookmark.assign_tags_from_names(tag_names_param)
      bookmark.assign_collections_from_ids(collection_ids_param)
      redirect_to bookmark, notice: "Saved to your library."
    else
      redirect_back fallback_location: new_bookmark_path, inertia: inertia_record_errors(bookmark)
    end
  end

  def edit
    render inertia: "bookmarks/Edit", props: new_edit_props(
      bookmark: bookmark_card_props(@bookmark).merge(
        tag_names: @bookmark.tags.order(:name).pluck(:name),
        collection_ids: @bookmark.collection_ids
      )
    )
  end

  def update
    @bookmark.assign_attributes(bookmark_params)
    attach_image(@bookmark)

    if @bookmark.save
      @bookmark.assign_tags_from_names(tag_names_param) if tag_names_submitted?
      @bookmark.assign_collections_from_ids(collection_ids_param) if collection_ids_submitted?
      redirect_to @bookmark, notice: "Bookmark updated."
    else
      redirect_back fallback_location: edit_bookmark_path(@bookmark), inertia: inertia_record_errors(@bookmark)
    end
  end

  def destroy
    @bookmark.destroy
    redirect_to bookmarks_path, notice: "Bookmark deleted."
  end

  private
    def set_bookmark
      @bookmark = Current.user.bookmarks.includes(:tags, :collections, image_attachment: :blob).find(params[:id])
    end

    def bookmark_params
      params.permit(:kind, :title, :url, :description)
    end

    def new_edit_props(bookmark:)
      {
        bookmark:,
        tags: tag_options,
        collections: collection_options
      }
    end

    def attach_image(bookmark)
      if params[:image].present?
        bookmark.image.attach(params[:image])
      elsif params[:preview_image_url].present? && !bookmark.image.attached?
        BookmarkImageAttacher.call(bookmark, params[:preview_image_url])
      end
    end

    def tag_names_submitted?
      params.key?(:tag_names)
    end

    def collection_ids_submitted?
      params.key?(:collection_ids)
    end

    def tag_names_param
      names = params[:tag_names]
      names = names.split(",") if names.is_a?(String)
      Array(names)
    end

    def collection_ids_param
      ids = params[:collection_ids]
      ids = ids.split(",") if ids.is_a?(String)
      Array(ids)
    end
end
