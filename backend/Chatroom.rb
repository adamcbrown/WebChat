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
    puts @key
    if !@users.include?(user)
      if password!=@password
        user.ws.send(JSON.generate({"type"=>"chatroomRefuse", "message"=>"Invalid Password"}))
      else
        @users<<user
        user.ws.send(JSON.generate({"type"=>"chatroomAccept", "key"=>[@key[0].to_s, @key[2].to_s]}))
      end
    else
      puts "Already Here"
    end
  end

  def removeUser(user)
    @users.delete(user)
  end

  def sendToAll(data)
    data["message"]=@eh.cypherText(data["message"], [@key[1], @key[2]])
    @users.each do |user|
      sendToUser(user, data)
    end
  end

  def sendToUser(user, data)
    if @eh==nil
      user.ws.send(data)
    else
      storeMessage=data["message"]
      data["message"]=@eh.cypherText(data["message"], user.key)
      user.ws.send(JSON.generate(data))
      data["message"]=storeMessage
    end
  end
end