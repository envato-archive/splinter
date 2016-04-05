require "splinter/capybara"

RSpec.configure do |config|
  config.include Splinter::Capybara::Actions, :type => :feature

  config.after :each, :type => :feature do |example|
    take_screenshot! if Splinter.screenshot_directory &&
      example.exception && example.metadata[:js]

    ::Capybara.reset_sessions!
  end
end
