# This is a hack that forces AR to share its connection between different
# threads. Useful for Capybara when you are not using rack-test.
class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || retrieve_connection
  end
end
