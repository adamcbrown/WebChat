require 'eventmachine'
require 'em-websocket'
require 'thin'
require 'JSON'
require 'sinatra/base'
require_relative './application_controller.rb'
require_relative './backend/ServerManager.rb'
require_relative './backend/EncryptionHelper.rb'


def run(opts)
  eh=EncryptionHelper.new
  key=eh.getKey
  puts key

  serverManager=ServerManager.new
  serverManager.createChatroom("Testing", "", eh)


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
          ws.send(JSON.generate({"type"=>"serverJoined", "key"=>[key[0].to_s, key[2].to_s]}))
        end

        ws.onclose do
          #serverManager.userLogOff(ws)
          #serverManager.saveUsers
          #EventMachine.stop
        end

        ws.onmessage do |packet|
          data=JSON.parse(packet)
          if data["type"]=="chatroomMessage"
            serverManager.sendToChatroom(ws, packet)
          elsif data["type"]=="chatroomJoin"
            data=JSON.parse(eh.decryptData(data["data"], [key[1], key[2]]))
            serverManager.addUserToChatroom(ws, data["name"], data["password"])
          elsif data["type"]=="createChatroom"
            data=JSON.parse(eh.decryptData(data["data"], [key[1], key[2]]))
            serverManager.createChatroom(data["name"], data["password"], eh)
          elsif data["type"]=="chatroomLeave"
            serverManager.leaveChatroom(ws)
          elsif data["type"]=="loginRequest"
            data=JSON.parse(eh.decryptData(data["data"], [key[1], key[2]]))

            if serverManager.validLogin(data["username"], data["password"])
              serverManager.addUser(ws, data["username"], data["key"])
              ws.send(JSON.generate({"type"=>"loginAccept"}))
            else
              ws.send(JSON.generate({"type"=>"loginRefuse", "message"=>"Invalid Username or Password"}))
            end
          elsif data["type"]=="registerUser"
            data=JSON.parse(eh.decryptData(data["data"], [key[1], key[2]]))
            if serverManager.userExists(data["username"])
               ws.send(JSON.generate({"type"=>"registerFailed", "message"=>"Username already exists"}))
            else
              serverManager.registerUser(data["username"], data["password"])
              ws.send(JSON.generate({"type"=>"loginAccept"}))
            end 
          else
            puts "UNRECOGNIZED TYPE: #{data["type"]}"
          end
        end
      end
    end

  end

end

run({:app=>ApplicationController})