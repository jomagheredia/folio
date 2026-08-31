# frozen_string_literal: true

class Collections::AiController < ApplicationController
  def summary
    collection = Current.user.collections.includes(bookmarks: :tags).find(params[:collection_id])
    result = CollectionAi.summarize(collection)
    render json: { ok: result.ok, error: result.error, summary: result.summary }
  end
end
