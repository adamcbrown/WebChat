require 'eventmachine'
require 'em-websocket'
require 'json'
require 'pry'
require 'thin'
require 'sinatra/base'

class ApplicationController < Sinatra::Base

  configure do
    set :threaded, false
  end

  get '/' do
    erb :'index'
  end

end