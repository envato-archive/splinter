require 'sinatra/base'

module Splinter
  class TestServer < Sinatra::Base
    set :root, File.dirname(__FILE__)

    get '/' do
      erb :index
    end

    post '/' do
      erb :index
    end
  end
end
