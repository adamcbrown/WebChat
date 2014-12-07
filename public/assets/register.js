$(document).ready(function(){

  var socket = new WebSocket("ws://localhost:8000");
  var serverEncryptKey;

  $("#register").click(function(event){
    var data=encryptText(JSON.stringify({"username":$("#username").val(),
                                        "password":$("#password").val()}), serverEncryptKey);
    socket.send(JSON.stringify({"type":"registerUser", "data":data}));
  });

  socket.onmessage=function(event){
    var data=JSON.parse(event.data);
    switch(data.type){
      case "serverJoined":
        serverEncryptKey=data.key;
        console.log(serverEncryptKey);
        break;
      case "loginAccept":
        alert("User is now registered!")
        window.location = "/";
        break;
      case "registerFailed":
        alert(data.message);
        break; 
    }
  };
});