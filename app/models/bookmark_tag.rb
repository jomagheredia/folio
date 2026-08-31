# frozen_string_literal: true

class BookmarkTag < ApplicationRecord
  belongs_to :bookmark
  belongs_to :tag

  validates :tag_id, uniqueness: { scope: :bookmark_id }
end
