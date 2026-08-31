# frozen_string_literal: true

class ShareMailer < ApplicationMailer
  def share_email(share, recipient)
    @share = share
    @sender = share.user
    @items = share.bookmarks.includes(image_attachment: :blob).map do |bookmark|
      {
        title: bookmark.title,
        url: bookmark.url,
        image_url: thumbnail_url(bookmark)
      }
    end

    mail(
      to: recipient,
      subject: share.subject,
      reply_to: @sender.email
    )
  end

  private
    def thumbnail_url(bookmark)
      return unless bookmark.image.attached?

      rails_blob_url(bookmark.image, expires_in: 1.year)
    end
end
