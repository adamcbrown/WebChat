require_relative "./Chatroom.rb"
require_relative "./User.rb"

class ServerManager

  def initialize
    @chatrooms=[]
    @users=[]

    @registeredUsers={}
  end

  def createChatroom(name, password, eh)
    @chatrooms<<Chatroom.new(name, password, eh)
  end

  def addUser(ws, name, key)
    @users<<User.new(ws, name, key)
  end

  def addUserToChatroom(ws, roomName, password)
    chatroom=findChatroomWithName(roomName)
    user=getUserFromWS(ws)
    if chatroom!=nil
      chatroom.addUser(user, password)
    else
      ws.send(JSON.generate({"type"=>"chatroomRefuse", "message"=>"Chatroom does not exist"}))
    end
  end

  def userLogOff(ws)
    user=getUserFromWS(ws)
    leaveChatroom(ws)
    @users.delete(user)
  end

  def leaveChatroom(ws)
    user=getUserFromWS(ws)
    chatroom=findChatroomWithUser(user)
    if chatroom!=nil
      chatroom.removeUser(user)
    end
  end

  def sendToChatroom(user, packet)
    chatroom=findChatroomWithUser(user)
    if chatroom!=nil
      chatroom.sendToAll(packet)
    end
  end

  def getUserFromWS(ws)
    @users.each do |user|
      if user.ws==ws
        return user
      end
    end
    return nil
  end

  def findChatroomWithUser(user)
    @chatrooms.each do |chatroom|
      chatroom.users.each_key do |user0|
        if user0==user.ws
          return chatroom
        end
      end
    end
    return nil
  end

  def findChatroomWithName(name)
    @chatrooms.each do |chatroom|
      if chatroom.name==name
        return chatroom
      end
    end
    return nil
  end

  def registerUser(username, password)
    @registeredUsers[username]=password
  end

  def userExists(username)
    @registeredUsers.has_key?(username)
  end

  def validLogin(username, password)
    return userExists(username) && @registeredUsers[username]==password
  end

  def saveUsers
    
  end
end