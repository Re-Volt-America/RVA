ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"
require "etc"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers

  # Disable parallelize on Windows as it causes Permission denied errors...
  unless Etc.uname[:sysname] == "Windows_NT"
    parallelize(workers: :number_of_processors, with: :threads)
  end

  # Add more helper methods to be used by all tests here...
end
