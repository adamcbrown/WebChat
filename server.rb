require 'eventmachine'
require 'em-websocket'
require 'thin'
require 'JSON'
require 'sinatra/base'
require_relative './application_controller.rb'
require_relative './backend/ServerManager.rb'


def run(opts)
  serverManager=ServerManager.new
  serverManager.createChatroom("Testing", "")
  EM.run do

    web_app=opts[:app]

    dispatch = Rack::Builder.app do
      map '/' do
        run web_app
      end
    end

    Rack::Server.start({
      app: dispatch,
      server: 'thin',
      Host: '0.0.0.0',
      Port: '8080'
    })

    EM.run do
      EM::WebSocket.run(:host=>"0.0.0.0", :port=>8000) do |ws|

        ws.onopen do
          ws.send(JSON.generate({"type"=>"serverJoined"}))
        end

        ws.onclose do
          serverManager.userLogOff(ws)
          EventMachine.stop
        end

        ws.onmessage do |packet|
          data=JSON.parse(packet)
          if data["type"]=="chatroomMessage"
            serverManager.sendToChatroom(ws, packet)
          elsif data["type"]=="chatroomJoin"
            serverManager.addUserToChatroom(ws, data["name"], data["password"])
          elsif data["type"]=="createChatroom"
            serverManager.createChatroom(data["name"], data["password"])
          elsif data["type"]=="assignName"
            serverManager.addUser(ws, data["user"])

          elsif data["type"]=="chatroomLeave"
            serverManager.leaveChatroom(ws)
          else
            puts "UNRECOGNIZED TYPE: #{data["type"]}"
          end
        end
      end
    end

  end

end

run({:app=>ApplicationController})