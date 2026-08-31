ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "minitest/mock"

module AuthenticationHelpers
  def log_in_as(user, password: "password")
    post login_path, params: { email: user.email, password: password }
  end
end

module AiTestHelpers
  def stub_openai(payload)
    OpenaiClient.fake_chat = ->(_messages) { payload }
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include AiTestHelpers

    teardown do
      OpenaiClient.fake_chat = nil
    end
  end
end

class ActionDispatch::IntegrationTest
  include AuthenticationHelpers
end
