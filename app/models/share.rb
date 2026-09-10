# frozen_string_literal: true

class Share < ApplicationRecord
  MAX_RECIPIENTS = 20

  belongs_to :user
  belongs_to :collection, optional: true
  has_many :share_bookmarks, dependent: :destroy
  has_many :bookmarks, through: :share_bookmarks

  before_validation :normalize_recipients

  validates :subject, presence: true
  validates :body, presence: true
  validates :sent_at, presence: true
  validate :recipients_must_be_valid
  validate :must_have_bookmarks, on: :create
  validate :collection_belongs_to_user
  validate :bookmarks_belong_to_user

  scope :newest_first, -> { order(sent_at: :desc) }

  def self.parse_recipients(raw)
    values = Array(raw).flat_map { |value| value.to_s.split(/[\s,;]+/) }
    values.map { |value| value.strip.downcase }.reject(&:blank?).uniq
  end

  def self.default_subject(bookmarks, collection: nil)
    return collection.name if collection.present?

    list = Array(bookmarks)
    return "Finds from Folio" if list.empty?
    return list.first.title if list.size == 1

    "#{list.first.title} and #{list.size - 1} more"
  end

  def self.default_body(bookmarks, collection: nil)
    parts = []
    summary = collection&.ai_summary.to_s.strip
    parts << summary if summary.present?

    Array(bookmarks).each do |bookmark|
      lines = [ bookmark.title, bookmark.url.presence || "(visual)" ]
      description = bookmark.description.to_s.strip
      summary = bookmark.summary.to_s.strip
      lines << description if description.present?
      lines << summary if summary.present? && summary != description
      parts << lines.join("\n")
    end

    parts.join("\n\n")
  end

  def deliver_to_recipients
    recipients.each do |email|
      ShareMailer.share_email(self, email).deliver_later
    end
  end

  private
    def normalize_recipients
      self.recipients = self.class.parse_recipients(recipients)
    end

    def recipients_must_be_valid
      if recipients.blank?
        errors.add(:recipients, "can't be blank")
        return
      end

      if recipients.size > MAX_RECIPIENTS
        errors.add(:recipients, "is too long (maximum is #{MAX_RECIPIENTS} addresses)")
        return
      end

      invalid = recipients.reject { |email| email.match?(URI::MailTo::EMAIL_REGEXP) }
      errors.add(:recipients, "contains an invalid address") if invalid.any?
    end

    def must_have_bookmarks
      errors.add(:bookmarks, "must include at least one bookmark") if bookmarks.empty?
    end

    def collection_belongs_to_user
      return if collection.blank? || user.blank?

      errors.add(:collection, "must belong to you") if collection.user_id != user_id
    end

    def bookmarks_belong_to_user
      return if user.blank?

      errors.add(:bookmarks, "must belong to you") if bookmarks.any? { |bookmark| bookmark.user_id != user_id }
    end
end
