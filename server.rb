require 'faye/websocket'
require 'redis'
require 'thin'
require 'JSON'
require 'sinatra/base'
require 'pry'
require_relative './application_controller.rb'
require_relative './backend/ServerManager.rb'
require_relative './backend/EncryptionHelper.rb'

class Server
    KEEPALIVE_TIME = 15 # in seconds
    CHANNEL        = "chat-demo"
  def initialize(app)
    @eh=EncryptionHelper.new
    @serverManager=ServerManager.new
    @key=@eh.getKey
    @app     = app
    # @clients = []
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    # Thread.new do
    #   redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
    #   redis_sub.subscribe(CHANNEL) do |on|
    #     on.message do |channel, msg|
    #       @clients.each {|ws| ws.send(msg) }
    #     end
    #   end
    # end
  end

  def call(env)
    if Faye::WebSocket.websocket?(env)

      ws = Faye::WebSocket.new(env, nil, {ping: KEEPALIVE_TIME })

      ws.on :open do
        ws.send(JSON.generate({"type"=>"serverJoined", "key"=>[@key[0].to_s, @key[2].to_s]}))
      end

      ws.on :close do

      end

      ws.on :message do |packet|
        data=JSON.parse(packet.data)
        if data["type"]=="chatroomMessage"
          @serverManager.sendToChatroom(data["user"], data)
        elsif data["type"]=="chatroomJoin"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          @serverManager.addUserToChatroom(ws, data["user"], data["name"], data["password"])
        elsif data["type"]=="chatroomCreate"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          @serverManager.createChatroom(data["name"], data["password"], @eh)
        elsif data["type"]=="chatroomLeave"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          @serverManager.leaveChatroom(data["username"])
        elsif data["type"]=="loginRequest"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          if @serverManager.validLogin(data["username"], data["password"])
            @serverManager.addUser(ws, data["username"], [data["key"][0].to_i, data["key"][1].to_i])
            ws.send(JSON.generate({"type"=>"loginAccept"}))
          else
            ws.send(JSON.generate({"type"=>"loginRefuse", "message"=>"Invalid Username or Password"}))
          end
        elsif data["type"]=="registerUser"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          if @serverManager.userExists(data["username"])
             ws.send(JSON.generate({"type"=>"registerFailed", "message"=>"Username already exists"}))
          else
            @serverManager.registerUser(data["username"], data["password"], data["email"])
            ws.send(JSON.generate({"type"=>"loginAccept"}))
          end
        elsif data["type"]=="loginCheck"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          if @serverManager.validLogin(data["username"], data["password"]) && @serverManager.userOnline(data["username"])
            @serverManager.resetWS(data["username"], ws)
          else
            ws.send(JSON.generate("type"=>"loginCheckFailed"))
          end
        elsif data["type"]=="userLogOff"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          @serverManager.userLogOff(data["username"])
        elsif data["type"]=="requestChatroom"
          data=JSON.parse(@eh.decryptData(data["data"], [@key[1], @key[2]]))
          user=@serverManager.getUserFromName(data["user"])
          if user!=nil
            data=@eh.cypherText(JSON.generate("chatrooms"=>@serverManager.getChatrooms).bytes, user.key);
            user.ws.send(JSON.generate({
                "type"=>"chatroomList",
                "chatrooms"=>data
              }))
          end
        else
          puts "UNRECOGNIZED TYPE: #{data["type"]}"
        end
      end
      
      ws.rack_response
    else
      @app.call(env)
    end
  end
end