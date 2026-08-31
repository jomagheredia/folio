require "test_helper"

class SafeHttpTest < ActiveSupport::TestCase
  test "rejects private ipv4 destinations" do
    error = assert_raises(SafeHttp::Error) { SafeHttp.get("http://127.0.0.1/") }
    assert_match(/blocked/, error.message)
  end

  test "rejects localhost" do
    error = assert_raises(SafeHttp::Error) { SafeHttp.get("http://localhost/") }
    assert_match(/blocked/, error.message)
  end

  test "rejects non-http schemes" do
    error = assert_raises(SafeHttp::Error) { SafeHttp.get("file:///etc/passwd") }
    assert_match(/http/, error.message)
  end

  test "rejects a blank or invalid url" do
    assert_raises(SafeHttp::Error) { SafeHttp.get("not a url") }
  end
end
