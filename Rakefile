$:.unshift 'lib'

begin
  require 'bundler'
  Bundler::GemHelper.install_tasks

  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new :spec do |t|
    t.rspec_opts = %w[--color --format documentation]
  end
rescue LoadError
  puts "Please install rspec (bundle install)"
  exit
end

task :default => :spec
