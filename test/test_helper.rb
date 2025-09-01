ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # fixtures :all

    # Permite usar create(:user), build(:user), etc.
    include FactoryBot::Syntax::Methods

    # Add more helper methods to be used by all tests here...
  end
end
