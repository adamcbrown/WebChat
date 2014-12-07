$(document).ready(function(){

  var socket = new WebSocket("ws://localhost:8000");
  var serverEncryptKey;

  $("#login").click(function(event){
    $.cookie("key_d", $("#key_d").val());
    $.cookie("username", $("#username").val());
    var data=encryptText(JSON.stringify({"username":$("#username").val(),
                                  "password":$("#password").val(),
                                  "key":[parseInt($("#key_e").val(), 10), parseInt($("#key_n").val(), 10)]}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"loginRequest",
                                  "data":data}));
  });

  socket.onmessage=function(event){
    var data=JSON.parse(event.data);
    switch(data.type){
      case "serverJoined":
        serverEncryptKey=data.key
        break;
      case "loginAccept":
        window.location = "/chatroom";
        break;
      case "loginRefuse":
        alert(data.message);
        break;
    }
  };
});