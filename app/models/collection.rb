# frozen_string_literal: true

class Collection < ApplicationRecord
  belongs_to :user
  has_many :collection_bookmarks, dependent: :destroy
  has_many :bookmarks, through: :collection_bookmarks

  validates :name, presence: true
end
