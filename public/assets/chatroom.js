$(document).ready(function(){
  var socket = new WebSocket("ws://localhost:8000");
  var decryptionKey = parseInt($.cookie("key_d"), 10);
  var chatEncryptionKey;
  var serverEncryptKey;
  var username=$.cookie("username");

  $(".lobbyEnabled").prop("disabled", false);
  $(".chatEnabled").prop("disabled", true);

  $("#sendText").click(function(event){
    socket.send(JSON.stringify({"type":"chatroomMessage",
                                "user":username,
                                "message":cypherText($("#enterText").val(), chatEncryptionKey)}));
  });

  $("#chatroomEnter").click(function(event){
    var data=encryptText(JSON.stringify({"user":username,
                                "name":$("#chatroomName").val(),
                                "password":$("#chatroomPassword").val()}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"chatroomJoin", "data":data}));
  });



  $("#chatroomLeave").click(function(event){
    socket.send(JSON.stringify({"type":"chatroomLeave"}));
    $(".lobbyEnabled").prop("disabled", false);
    $(".chatEnabled").prop("disabled", true);
  });

  socket.onmessage=function(event){
    console.log(event.data)
    var data=JSON.parse(event.data);
    switch(data.type){
      case "serverJoined":
        serverEncryptKey=data.key
        break;
      case "chatroomMessage":
        var array=data.message.split(",");
        for(var i=0; i<array.length; i++){
          array[i] = parseInt(array[i], 10);
        }
        var textOut="<br>"+data.user+": "+decypherText(array, decryptionKey);
        document.getElementById("chatbox").innerHTML+=textOut;
        break;
      case "chatroomRefuse":
        alert(data.message);
        break;
      case "chatroomAccept":
        $(".lobbyEnabled").prop("disabled", true);
        $(".chatEnabled").prop("disabled", false);
        chatEncryptionKey=data.key;
        break;
    }
  };
});