# Preview all emails at http://localhost:3000/rails/mailers/share_mailer
class ShareMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/share_mailer/share_email
  def share_email
    share = Share.includes(:user, bookmarks: { image_attachment: :blob }).first || Share.new(
      user: User.first,
      subject: "A few finds",
      body: "Example Article\nhttps://example.com/article",
      note: "Thought you'd like these.",
      recipients: [ "friend@example.com" ],
      sent_at: Time.current
    )
    recipient = share.recipients.first.presence || "friend@example.com"
    ShareMailer.share_email(share, recipient)
  end
end
