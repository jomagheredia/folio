# frozen_string_literal: true

class Tag < ApplicationRecord
  belongs_to :user
  has_many :bookmark_tags, dependent: :destroy
  has_many :bookmarks, through: :bookmark_tags

  normalizes :name, with: ->(n) { n.strip }

  validates :name, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
end
