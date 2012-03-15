ENV["RACK_ENV"] ||= "test"

require "rspec"
require "capybara/rspec"
require "splinter"
require "splinter/rspec"

# Capybara setup
Capybara.default_driver   = :rack_test
Capybara.default_selector = :css
