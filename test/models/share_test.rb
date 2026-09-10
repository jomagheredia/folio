require "test_helper"

class ShareTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @bookmark = bookmarks(:one)
  end

  test "parses and normalizes recipient lists" do
    assert_equal %w[a@example.com b@example.com], Share.parse_recipients("A@example.com, b@example.com")
    assert_equal %w[a@example.com c@example.com], Share.parse_recipients("a@example.com; C@example.com\na@example.com")
  end

  test "requires at least one valid recipient" do
    share = @user.shares.new(share_attrs.merge(recipients: []))
    share.bookmarks << @bookmark
    assert_not share.valid?
    assert_includes share.errors[:recipients], "can't be blank"
  end

  test "rejects an invalid recipient address" do
    share = @user.shares.new(share_attrs.merge(recipients: [ "not-an-email" ]))
    share.bookmarks << @bookmark
    assert_not share.valid?
    assert_includes share.errors[:recipients], "contains an invalid address"
  end

  test "caps recipients at 20" do
    emails = (1..21).map { |n| "person#{n}@example.com" }
    share = @user.shares.new(share_attrs.merge(recipients: emails))
    share.bookmarks << @bookmark
    assert_not share.valid?
    assert_includes share.errors[:recipients], "is too long (maximum is 20 addresses)"
  end

  test "requires at least one bookmark on create" do
    share = @user.shares.new(share_attrs)
    assert_not share.valid?
    assert_includes share.errors[:bookmarks], "must include at least one bookmark"
  end

  test "cannot attach another user's bookmark" do
    share = @user.shares.new(share_attrs)
    share.bookmarks << bookmarks(:other_user)
    assert_not share.valid?
    assert_includes share.errors[:bookmarks], "must belong to you"
  end

  test "cannot point at another user's collection" do
    share = @user.shares.new(share_attrs.merge(collection: collections(:other_user)))
    share.bookmarks << @bookmark
    assert_not share.valid?
    assert_includes share.errors[:collection], "must belong to you"
  end

  test "default subject uses the collection name" do
    assert_equal "Spring campaign refs", Share.default_subject([ @bookmark ], collection: collections(:spring))
  end

  test "default subject falls back to titles" do
    second = @user.bookmarks.create!(kind: :link, title: "Second find", url: "https://example.com/second")
    assert_equal "Example Article", Share.default_subject([ @bookmark ])
    assert_equal "Example Article and 1 more", Share.default_subject([ @bookmark, second ])
  end

  test "default body includes ai summary titles urls and descriptions" do
    collection = collections(:spring)
    collection.update!(ai_summary: "A quiet set of launch refs.")

    body = Share.default_body([ @bookmark ], collection: collection)
    assert_includes body, "A quiet set of launch refs."
    assert_includes body, "Example Article"
    assert_includes body, "https://example.com/article"
    assert_includes body, "A short snippet about design systems"
  end

  test "default body includes a bookmark summary when present" do
    @bookmark.update!(summary: "A one-line overview of the article.")

    body = Share.default_body([ @bookmark ])
    assert_includes body, "Example Article"
    assert_includes body, "A short snippet about design systems"
    assert_includes body, "A one-line overview of the article."
  end

  test "destroying a bookmark keeps the share snapshot" do
    share = shares(:spring_sent)
    assert_difference -> { Bookmark.count }, -1 do
      assert_no_difference -> { Share.count } do
        @bookmark.destroy
      end
    end
    assert Share.exists?(share.id)
    assert_equal "Spring campaign refs", share.reload.subject
  end

  test "destroying a collection destroys its shares" do
    assert_difference -> { Share.count }, -1 do
      collections(:spring).destroy
    end
  end

  private
    def share_attrs
      {
        recipients: [ "friend@example.com" ],
        subject: "A few finds",
        body: "Example Article\nhttps://example.com/article",
        sent_at: Time.current
      }
    end
end
