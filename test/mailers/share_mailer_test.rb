require "test_helper"

class ShareMailerTest < ActionMailer::TestCase
  test "html and text parts include sender note titles and links" do
    share = shares(:spring_sent)
    email = ShareMailer.share_email(share, "friend@example.com")

    assert_equal [ "friend@example.com" ], email.to
    assert_equal share.subject, email.subject
    assert_equal [ users(:one).email ], email.reply_to

    html = email.html_part.body.to_s
    text = email.text_part.body.to_s

    assert_includes html, users(:one).email
    assert_includes html, "Thought you'd like these."
    assert_includes html, "Example Article"
    assert_includes html, "https://example.com/article"
    assert_includes text, "Example Article"
    assert_includes text, "Thought you'd like these."
    refute_includes html, "Sign up"
  end

  test "includes a thumbnail url when the bookmark has an image" do
    bookmark = bookmarks(:one)
    bookmark.image.attach(
      io: File.open(file_fixture("test.png")),
      filename: "test.png",
      content_type: "image/png"
    )
    share = shares(:spring_sent)
    html = ShareMailer.share_email(share, "friend@example.com").html_part.body.to_s

    assert_includes html, "<img"
    assert_includes html, "example.com"
  end
end
