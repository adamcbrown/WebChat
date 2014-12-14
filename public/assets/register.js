$(document).ready(function(){

  var socket = new WebSocket("ws://"+window.document.location.host+":8000");
  var serverEncryptKey;

  $("#register").click(function(event){
    if($("#username").val()==""||$("#password").val()==""||$("#email").val()==""){
      alert("Please fill in all values")
      return;
    }
    var data=encryptText(JSON.stringify({"username":$("#username").val(),
                                        "password":$("#password").val(),
                                        "email":$("#email").val()}), serverEncryptKey);
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