# frozen_string_literal: true

class ShareBookmark < ApplicationRecord
  belongs_to :share
  belongs_to :bookmark

  validates :bookmark_id, uniqueness: { scope: :share_id }
end
