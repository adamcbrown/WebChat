require_relative "./Chatroom.rb"

class ServerManager
  CHATROOMS=[]
  USERS={}

  def createChatroom(name, password)
    CHATROOMS<<Chatroom.new(name, password)
  end

  def addUser(ws, name)
    USERS[ws]=name
  end

  def addUserToChatroom(ws, roomName, password)
    chatroom=findChatroomWithName(roomName)
    if chatroom!=nil
      chatroom.addUser(ws, USERS[ws], password)
    else
      ws.send(JSON.generate({"type"=>"chatroomRefuse", "message"=>"Chatroom does not exist"}))
    end
  end

  def userLogOff(ws)
    leaveChatroom(ws)
    USERS.delete(ws)
  end

  def leaveChatroom(ws)
    chatroom=findChatroomWithUser(ws)
    if chatroom!=nil
      chatroom.removeUser(ws)
    end
  end

  def sendToChatroom(ws, packet)
    chatroom=findChatroomWithUser(ws)
    if chatroom!=nil
      chatroom.sendToAll(packet)
    end
  end

  def findChatroomWithUser(ws)
    CHATROOMS.each do |chatroom|
      chatroom.users.each_key do |user|
        if user==ws
          return chatroom
        end
      end
    end
    return nil
  end

  def findChatroomWithName(name)
    CHATROOMS.each do |chatroom|
      if chatroom.name==name
        return chatroom
      end
    end
    return nil
  end
end