# frozen_string_literal: true

class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_bookmarks, dependent: :destroy
  has_many :bookmarks, through: :collection_bookmarks
  has_many :shares, dependent: :destroy

  validates :name, presence: true
end
