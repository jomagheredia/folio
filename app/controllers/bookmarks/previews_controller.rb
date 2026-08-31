# frozen_string_literal: true

class Bookmarks::PreviewsController < ApplicationController
  def create
    result = BookmarkUnfurl.call(url: params[:url], user: Current.user)
    payload = {
      ok: result.ok,
      error: result.error,
      title: result.title,
      description: result.description,
      image_url: result.image_url,
      duplicate: result.duplicate,
      existing: result.existing && {
        id: result.existing[:id],
        title: result.existing[:title],
        path: bookmark_path(result.existing[:id])
      }
    }
    render json: payload
  end
end
