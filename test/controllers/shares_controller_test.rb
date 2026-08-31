require "test_helper"

class SharesControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @user = users(:one)
    log_in_as(@user)
    ActionMailer::Base.deliveries.clear
  end

  test "unauthenticated users are redirected to login" do
    delete logout_path
    get new_share_path, params: { collection_id: collections(:spring).id }
    assert_redirected_to login_path
  end

  test "new from a collection pre-fills subject and body" do
    get new_share_path, params: { collection_id: collections(:spring).id }
    assert_response :success
    assert_includes response.body, "Spring campaign refs"
    assert_includes response.body, "Example Article"
  end

  test "new from bookmark ids pre-fills a title subject" do
    get new_share_path, params: { bookmark_ids: [ bookmarks(:one).id ] }
    assert_response :success
    assert_includes response.body, "Example Article"
  end

  test "new without bookmarks redirects" do
    get new_share_path
    assert_redirected_to bookmarks_path
  end

  test "cannot compose another user's collection" do
    get new_share_path, params: { collection_id: collections(:other_user).id }
    assert_redirected_to bookmarks_path
  end

  test "creates a collection share and sends one email per recipient" do
    assert_difference -> { @user.shares.count }, 1 do
      perform_enqueued_jobs do
        post shares_path, params: {
          collection_id: collections(:spring).id,
          bookmark_ids: [ bookmarks(:one).id ],
          recipients: "a@example.com, B@example.com",
          subject: "Spring campaign refs",
          note: "Take a look",
          body: "Example Article\nhttps://example.com/article"
        }
      end
    end

    share = @user.shares.newest_first.first
    assert_redirected_to collection_path(collections(:spring))
    assert_equal %w[a@example.com b@example.com], share.recipients
    assert_equal "Take a look", share.note
    assert_includes share.bookmarks, bookmarks(:one)

    deliveries = ActionMailer::Base.deliveries
    assert_equal 2, deliveries.size
    assert_equal %w[a@example.com b@example.com], deliveries.map { |mail| mail.to.first }.sort
    deliveries.each do |mail|
      assert_equal [ @user.email ], mail.reply_to
      assert_equal "Spring campaign refs", mail.subject
      assert_includes mail.html_part.body.to_s, "Take a look"
      assert_includes mail.html_part.body.to_s, "Example Article"
      assert_includes mail.text_part.body.to_s, "Example Article"
    end
  end

  test "creates an ad-hoc share and redirects to the library" do
    perform_enqueued_jobs do
      post shares_path, params: {
        bookmark_ids: [ bookmarks(:one).id ],
        recipients: "solo@example.com",
        subject: "Example Article",
        body: "Example Article\nhttps://example.com/article"
      }
    end

    share = @user.shares.newest_first.first
    assert_redirected_to bookmarks_path
    assert_nil share.collection_id
    assert_equal 1, ActionMailer::Base.deliveries.size
  end

  test "cannot share another user's bookmark" do
    assert_no_difference -> { Share.count } do
      post shares_path, params: {
        bookmark_ids: [ bookmarks(:other_user).id ],
        recipients: "a@example.com",
        subject: "Nope",
        body: "Nope"
      }
    end

    assert_response :redirect
  end

  test "rejects invalid recipients" do
    assert_no_difference -> { Share.count } do
      post shares_path, params: {
        collection_id: collections(:spring).id,
        bookmark_ids: [ bookmarks(:one).id ],
        recipients: "not-an-email",
        subject: "Spring campaign refs",
        body: "Example Article"
      }
    end

    assert_response :redirect
  end
end
