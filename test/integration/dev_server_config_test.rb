# frozen_string_literal: true

require "test_helper"
require "json"

class DevServerConfigTest < ActiveSupport::TestCase
  test "development Vite host is IPv4 loopback so Rails can reach the dev server" do
    config = JSON.parse(File.read(Rails.root.join("config/vite.json")))

    assert_equal "127.0.0.1", config.dig("development", "host")
    assert_nil config.dig("test", "host")
  end

  test "Procfile.dev keeps processes alive and binds Rails on all IPv4 addresses" do
    procfile = File.read(Rails.root.join("Procfile.dev"))

    assert_match(%r{^web: bin/keep-alive bin/rails s -b 0\.0\.0\.0$}, procfile)
    assert_match(%r{^vite: bin/keep-alive bin/vite dev$}, procfile)
    assert_match(%r{^jobs: bin/keep-alive bin/jobs$}, procfile)
  end

  test "bin/keep-alive is executable and restarts on crash" do
    keep_alive = Rails.root.join("bin/keep-alive")

    assert keep_alive.executable?, "#{keep_alive} should be executable"
    source = keep_alive.read
    assert_includes source, "restarting in 1s"
    assert_includes source, "command -v setsid"
    assert_includes source, "use_setsid"
    assert_includes source, "stopping=0"
    refute_includes source, "code -eq 143"
  end
end
