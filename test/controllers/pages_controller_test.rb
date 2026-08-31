require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "root renders the public home when signed out" do
    get root_path
    assert_response :success
  end

  test "root redirects signed-in users to the library" do
    log_in_as(users(:one))
    get root_path
    assert_redirected_to bookmarks_path
  end
end
