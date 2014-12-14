require 'sinatra'
require './application_controller'
require './server.rb'

use Server
run ApplicationController