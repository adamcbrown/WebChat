require_relative "./Chatroom.rb"
require_relative "./User.rb"

class ServerManager

  attr_reader :chatrooms;

  def initialize
    @chatrooms=[]
    @users=[]

    @registeredUsers={}
    @registeredUserEmails={}
  end

  def createChatroom(name, password, eh)
    create=true
    chatrooms.each do |chatroom|
      if chatroom.name==name
        create=false
      end
    end

    if create
      @chatrooms<<Chatroom.new(name, password, eh)
    end
  end

  def addUser(ws, name, key)
    @users<<User.new(ws, name, key)
  end

  def addUserToChatroom(ws, username, roomName, password)
    chatroom=findChatroomWithName(roomName)
    user=getUserFromName(username)
    if chatroom!=nil
      chatroom.addUser(user, password)
    else
      user.ws.send(JSON.generate({"type"=>"chatroomRefuse", "message"=>"Chatroom does not exist"}))
    end
  end

  def userOnline(username)
    @users.each do |user|
      if user.name==username
        return true
      end
    end
    return false
  end

  def userLogOff(name)
    user=getUserFromName(name)
    leaveChatroom(name)
    @users.delete(user)
  end

  def leaveChatroom(name)
    user=getUserFromName(name)
    chatroom=findChatroomWithUser(name)
    if chatroom!=nil
      chatroom.removeUser(user)
    end
  end

  def sendToChatroom(user, data)
    chatroom=findChatroomWithUser(user)
    if chatroom!=nil
      chatroom.sendToAll(data)
    end
  end

  def getUserFromName(username)
    @users.each do |user|
      if user.name==username
        return user
      end
    end
    return nil
  end

  def findChatroomWithUser(user)
    @chatrooms.each do |chatroom|
      chatroom.users.each do |user0|
        if user0.name==user
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

  def registerUser(username, password, email)
    @registeredUsers[username]=password
    @registeredUserEmails[username]=email
  end

  def userExists(username)
    @registeredUsers.has_key?(username)
  end

  def resetWS(username, ws)
    user=getUserFromName(username)
    if user!=nil
      user.ws=ws
    end
  end

  def validLogin(username, password)
    return userExists(username) && @registeredUsers[username]==password
  end

  def getChatrooms
    chatrooms.collect do |chatroom|
      chatroom.name
    end
  end

  def saveUsers
    
  end
end