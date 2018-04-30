require 'simplecov'
SimpleCov.start

require 'database_cleaner'
require 'ffaker'


RSpec.configure do |config|
  config.mock_with :rspec
  
  # Clean out the database state before the tests run
  
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.order = :random
end
