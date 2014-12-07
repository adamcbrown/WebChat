class Chatroom
  attr_reader :name, :password, :users, :key

  def initialize(name, password, eh)
    @name=name
    @password=password
    @users=[]
    @eh=eh
    @key=eh.getKey
  end

  def addUser(user, password)
    if !@users.include?(user)
      if password!=@password
        user.ws.send(JSON.generate({"type"=>"chatroomRefuse", "message"=>"Invalid Password"}))
      else
        @users<<user
        user.ws.send(JSON.generate({"type"=>"chatroomAccept", "key"=>[key[0], key[2]]}))
      end
    end
  end

  def removeUser(user)
    @users.delete(user)
  end

  def sendToAll(packet)
    packet=@eh.cypherText(packet, [key[1], key[2]])
    @users.each do |user|
      sendToUser(user, packet)
    end
  end

  def sendToUser(user, packet)
    if eh==nil
      user.ws.send(packet)
    else
      user.ws.send(@eh.cypherText(packet.bytes, user.key).join(","))
    end
  end
end