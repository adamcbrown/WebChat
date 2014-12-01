class Chatroom
  attr_reader :name, :password, :users

  def initialize(name, password)
    @name=name
    @password=password
    @users={}
  end

  def addUser(ws, name, password)
    if !users.has_key?(ws)
      if password!=@password
        ws.send(JSON.generate({"type"=>"chatroomRefuse", "message"=>"Invalid Password"}))
      else
        users[ws]=name
        ws.send(JSON.generate({"type"=>"chatroomAccept"}))
      end
    end
  end

  def removeUser(user)
    users.delete(user)
  end

  def sendToAll(packet)
    users.each_key do |ws|
      ws.send(packet)
    end
  end
end