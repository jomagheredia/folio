# frozen_string_literal: true

class TagsController < ApplicationController
  include LibrarySerialization

  before_action :set_tag, only: %i[ show update destroy ]

  def index
    tags = Current.user.tags.left_joins(:bookmarks).select("tags.*, COUNT(bookmarks.id) AS bookmarks_count").group("tags.id").order(:name)

    render inertia: "tags/Index", props: {
      tags: tags.map { |tag| tag_props(tag, bookmarks_count: tag.bookmarks_count) }
    }
  end

  def show
    bookmarks = @tag.bookmarks.includes(:tags, :collections, image_attachment: :blob).newest_first

    render inertia: "tags/Show", props: {
      tag: tag_props(@tag, bookmarks_count: bookmarks.size),
      bookmarks: bookmarks.map { |bookmark| bookmark_card_props(bookmark) }
    }
  end

  def update
    if @tag.update(tag_params)
      redirect_to @tag, notice: "Tag renamed."
    else
      redirect_back fallback_location: tag_path(@tag), inertia: inertia_record_errors(@tag)
    end
  end

  def destroy
    @tag.destroy
    redirect_to tags_path, notice: "Tag deleted. Bookmarks are still in your library."
  end

  private
    def set_tag
      @tag = Current.user.tags.find(params[:id])
    end

    def tag_params
      params.permit(:name)
    end
end
