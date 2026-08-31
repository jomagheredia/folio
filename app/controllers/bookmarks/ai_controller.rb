# frozen_string_literal: true

class Bookmarks::AiController < ApplicationController
  before_action :set_bookmark

  def description
    result = BookmarkAi.describe(@bookmark)
    render json: { ok: result.ok, error: result.error, description: result.description }
  end

  def tags
    result = BookmarkAi.suggest_tags(@bookmark)
    render json: { ok: result.ok, error: result.error, tags: result.tags }
  end

  private
    def set_bookmark
      @bookmark = Current.user.bookmarks.includes(:tags, :user, image_attachment: :blob).find(params[:bookmark_id])
    end
end
