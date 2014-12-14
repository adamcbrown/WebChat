require 'eventmachine'
require 'em-websocket'
require 'json'
require 'pry'
require 'thin'
require 'sinatra/base'
require_relative "backend/EncryptionHelper.rb"

class ApplicationController < Sinatra::Base

  configure do
    set :threaded, false
  end

  get '/' do
    @eh=EncryptionHelper.new
    erb :'index'
  end

  get '/chatroom' do
    erb :'chatroom'
  end

  get '/register' do
    erb :'register'
  end

end