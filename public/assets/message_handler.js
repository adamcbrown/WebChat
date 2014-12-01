$(document).ready(function(){
  var socket = new WebSocket("ws://localhost:8000");

  $(".lobbyEnabled").prop("disabled", false);
  $(".chatEnabled").prop("disabled", true);

  $("#sendText").click(function(event){
    socket.send(JSON.stringify({"type":"chatroomMessage",
                                "user":"DEFAULT",
                                "message":$("#enterText").val()}));
  });

  $("#chatroomEnter").click(function(event){
    socket.send(JSON.stringify({"type":"chatroomJoin",
                                "user":"DEFAULT",
                                "name":$("#chatroomName").val(),
                                "password":$("#chatroomPassword").val()}));
  });

  $("#chatroomLeave").click(function(event){
    socket.send(JSON.stringify({"type":"chatroomLeave",
                                "user":"DEFAULT"}));
    $(".lobbyEnabled").prop("disabled", false);
    $(".chatEnabled").prop("disabled", true);
  });

  socket.onmessage=function(event){
    console.log(event.data)
    var data=JSON.parse(event.data);
    switch(data.type){
      case "chatroomMessage":
        var textOut="<br>"+data.user+": "+data.message;
        document.getElementById("chatbox").innerHTML+=textOut;
        break;
      case "chatroomRefuse":
        alert(data.message);
        break;
      case "chatroomAccept":
        $(".lobbyEnabled").prop("disabled", true);
        $(".chatEnabled").prop("disabled", false);
      case "serverJoined":
        socket.send(JSON.stringify({"type":"assignName",
                                    "user":"DEFAULT"}));
        break;
    }
  };
});