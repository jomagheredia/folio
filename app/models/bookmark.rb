# frozen_string_literal: true

class Bookmark < ApplicationRecord
  IMAGE_TYPES = %w[image/png image/jpeg image/webp image/gif].freeze
  MAX_IMAGE_SIZE = 10.megabytes

  belongs_to :user
  has_one_attached :image
  has_many :bookmark_tags, dependent: :destroy
  has_many :tags, through: :bookmark_tags
  has_many :collection_bookmarks, dependent: :destroy
  has_many :collections, through: :collection_bookmarks

  enum :kind, { link: 0, visual: 1 }

  scope :newest_first, -> { order(created_at: :desc) }

  before_validation :apply_default_title

  validates :title, presence: true
  validates :kind, presence: true
  validates :url, presence: true, if: :link?
  validate :url_must_be_http
  validate :visual_has_image
  validate :acceptable_image

  def self.search(query)
    return all if query.blank?

    pattern = "%#{sanitize_sql_like(query.strip)}%"
    matching_ids = left_outer_joins(:tags).where(
      "bookmarks.title ILIKE :q OR COALESCE(bookmarks.description, '') ILIKE :q OR COALESCE(bookmarks.url, '') ILIKE :q OR tags.name ILIKE :q",
      q: pattern
    ).select(:id)

    where(id: matching_ids)
  end

  def assign_tags_from_names(names)
    names = Array(names).map { |name| name.to_s.strip }.reject(&:blank?)
    names.uniq! { |name| name.downcase }

    self.tags = names.map do |name|
      user.tags.where("LOWER(name) = ?", name.downcase).first || user.tags.create!(name: name)
    end
  end

  def assign_collections_from_ids(ids)
    ids = Array(ids).map(&:to_i).reject(&:zero?)
    self.collections = user.collections.where(id: ids)
  end

  private
    def apply_default_title
      return if title.to_s.strip.present?

      fallback = image.attached? ? image.filename.to_s : nil
      self.title = fallback.presence || "Untitled"
    end

    def visual_has_image
      return unless visual?
      errors.add(:image, "can't be blank") unless image.attached?
    end

    def url_must_be_http
      return if url.blank?

      uri = URI.parse(url)
      unless uri.is_a?(URI::HTTP) && uri.host.present?
        errors.add(:url, "must be a valid http(s) URL")
      end
    rescue URI::InvalidURIError
      errors.add(:url, "must be a valid http(s) URL")
    end

    def acceptable_image
      return unless image.attached?

      unless image.content_type.in?(IMAGE_TYPES)
        errors.add(:image, "must be a PNG, JPG, WebP, or GIF")
      end

      if image.byte_size > MAX_IMAGE_SIZE
        errors.add(:image, "is too large (maximum 10MB)")
      end
    end
end
