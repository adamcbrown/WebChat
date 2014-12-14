$(document).ready(function(){
  var socket = new WebSocket("ws://"+window.document.location.host+":8000");
  var decryptionKey = [$.cookie("key_d"), $.cookie("key_n")];
  var chatEncryptionKey;
  var serverEncryptKey;
  var username=$.cookie("username");

  var refreshChatrooms=function(){
    var data=encryptText(JSON.stringify({
      "user":username
    }), serverEncryptKey);

    socket.send(JSON.stringify({
      "type":"requestChatroom",
      "data":data
    }));
  }

  $(".lobbyEnabled").prop("disabled", false);
  $(".chatEnabled").prop("disabled", true);

  $("#sendText").click(function(event){
    socket.send(JSON.stringify({"type":"chatroomMessage",
                                "user":username,
                                "message":encryptText($("#enterText").val(), chatEncryptionKey)}));
  });

  $("#refreshChatroom").click(function(event){
    refreshChatrooms();
  });

  $("#chatroomEnter").click(function(event){
    var data=encryptText(JSON.stringify({"user":username,
                                "name":$("#chatroomName").val(),
                                "password":$("#chatroomPassword").val()}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"chatroomJoin", "data":data}));
  });



  $("#chatroomLeave").click(function(event){
    var data=encryptText(JSON.stringify({"username":username}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"chatroomLeave",
                              "data":data}));
    $(".lobbyEnabled").prop("disabled", false);
    $(".chatEnabled").prop("disabled", true);
    refreshChatrooms();
  });

  $("#createChatroom").click(function(event){
    var data=encryptText(JSON.stringify({"name":$("#chatroomName").val(),
                                "password":$("#chatroomPassword").val()}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"chatroomCreate", "data":data}));
    refreshChatrooms();
  });

  window.onbeforeunload = function(){
    var data=encryptText(JSON.stringify({"username":username}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"userLogOff",
                              "data":data}));
    $.cookie("username", null);
    $.cookie("password", null);
  }

  socket.onmessage=function(event){
    console.log(event.data)
    var data=JSON.parse(event.data);
    switch(data.type){
      case "serverJoined":
        serverEncryptKey=data.key;
        var data=encryptText(JSON.stringify({"username":username,
                                  "password":$.cookie("password")}), serverEncryptKey);
        socket.send(JSON.stringify({"type":"loginCheck",
                                  "data":data}));
        refreshChatrooms();
        break;
      case "chatroomMessage":
        var textOut="<br>"+data.user+": "+decryptText(data.message, decryptionKey);
        document.getElementById("chatbox").innerHTML+=textOut;
        break;
      case "chatroomRefuse":
        alert(data.message);
        break;
      case "chatroomAccept":
        $(".lobbyEnabled").prop("disabled", true);
        $(".chatEnabled").prop("disabled", false);
        chatEncryptionKey=data.key;
        console.log(chatEncryptionKey);
        $("#chatbox").html("");
        break;
      case "loginCheckFailed":
        document.body.innerHTML = '';
        setTimeout(function (){
          window.location="/";
        }, 200);
        break;
      case "chatroomList":
        var chatrooms=JSON.parse(decryptText(data.chatrooms, decryptionKey)).chatrooms;
        console.log(chatrooms);
        $("#chatbox").html("");
        for(var i=0;i<chatrooms.length;i++){
          $("#chatbox").append(chatrooms[i]+"<br>");
        }
    }
  };
});