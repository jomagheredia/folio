# frozen_string_literal: true

class CollectionBookmark < ApplicationRecord
  belongs_to :collection
  belongs_to :bookmark

  validates :bookmark_id, uniqueness: { scope: :collection_id }
end
