$:.unshift 'lib'

require 'splinter/version'

Gem::Specification.new do |s|
  s.platform   = Gem::Platform::RUBY
  s.name       = 'splinter'
  s.version    = Splinter::Version
  s.date       = Time.now.strftime('%Y-%m-%d')
  s.summary    = 'Splinter is a Capybara Ninja'
  s.homepage   = 'https://github.com/site5/splinter'
  s.authors    = ['Joshua Priddle']
  s.email      = 'jpriddle@me.com'

  s.files      = %w[ Rakefile README.markdown ]
  s.files     += Dir['lib/**/*', 'spec/**/*']

  s.add_dependency 'capybara'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'sinatra'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rack-test'

  s.extra_rdoc_files = ['README.markdown']
  s.rdoc_options     = ["--charset=UTF-8"]
end
