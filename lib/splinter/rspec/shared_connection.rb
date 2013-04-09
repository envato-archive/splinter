require 'splinter/perf/shared_connection'

RSpec.configure do |config|
  config.before :all do
    # Forces all threads to share the same connection. This works on
    # Capybara because it starts the web server in a thread.
    ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection
  end
end
