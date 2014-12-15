$(document).ready(function(){
  var socket = new WebSocket("wss://"+window.document.location.host+"/");
  var serverEncryptKey;

  $("#login").click(function(event){
    var data=encryptText(JSON.stringify({"username":$("#username").val(),
                                  "password":$("#password").val(),
                                  "key":[$("#key_e").val(), $("#key_n").val()]}), serverEncryptKey);
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
        $.cookie("key_d", $("#key_d").val());
        $.cookie("key_n", $("#key_n").val())
        $.cookie("username", $("#username").val());
        $.cookie("password", $("#password").val());
        window.location = "/chatroom";
        break;
      case "loginRefuse":
        alert(data.message);
        break;
    }
  };
});