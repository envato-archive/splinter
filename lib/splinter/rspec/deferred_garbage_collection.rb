require 'splinter/perf/deferred_garbage_collection'

RSpec.configure do |config|
  config.before :all do
    Splinter::DeferredGarbageCollection.start
  end

  config.after :all do
    Splinter::DeferredGarbageCollection.reconsider
  end
end
