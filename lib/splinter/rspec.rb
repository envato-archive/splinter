require "splinter/capybara"

RSpec.configure do |config|
  config.include Splinter::Capybara::Actions, :type => :request

  config.after :each, :type => :request do
    take_screenshot! if Splinter.screenshot_directory &&
      example.exception && example.metadata[:js]

    ::Capybara.reset_sessions!
  end
end
