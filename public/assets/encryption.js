//Fast Modular Exponentiation
//by Cameron

//converts a non-negative integer to 
//binary represented by a string of 1s and 0s 
var numtobin=function(num){
    var bintext="";
    var bits=Math.floor(Math.log(num)/Math.log(2))+1;
    var currentnum=num;
    for(var i=0;i<bits;i++){
        bintext= currentnum%2 + bintext;
        currentnum=Math.floor(currentnum/2);
    }
    return bintext;
};

//converts a binary number (represented by a string of 1s
//and 0s) to a non-negative integer 
var bintonum=function(binchars){
    var binnum=0;
    var multiplier=1;
    for(var i=0;i<binchars.length;i++){
        if(binchars[binchars.length-i-1]==="1"){
            binnum += 1*multiplier;    
        }
        multiplier*=2;
    }
    return binnum;
};

//calculates A mod B (using quotient remainder theorem)
var mymod=function(A,B){
    //A=B*Q+R, where  0 <= R < B
    //A mod B = R
    //R= A-B*Q, Q=floor(A/B)
    A=new BigNumber(A);
    B=new BigNumber(B);
    return A.mod(B);
};

//calculates A^B mod C using fast modular exponentiation
var fastmodexp=function(A,B,C){

    var binB= numtobin(B);
    
    var Bdigits= binB.length;
    
    var AtoBmodC=[];
    
    var power=1;
    var product=0;
    for(var i=0; i<Bdigits; i++){
        if(i===0){
            AtoBmodC[0]= mymod(A,C);
        }
        else{
            AtoBmodC[i]= mymod(AtoBmodC[i-1]*AtoBmodC[i-1], C);
        }

        
       
        if(binB.charAt(Bdigits-1-i)==="1"){
            
            if(product===0){
                product= AtoBmodC[i];
            }else{
                product *= AtoBmodC[i];
            }
            product=mymod(product,C);
        }
        
        power *=2;
    }
    
    var result=mymod(product,C);
    return result;
};

function bytesToString(bytes) {
  var str="";
  for(var i=0;i<bytes.length;i++){
    str+=String.fromCharCode(bytes[i]);
  }
  return str;
}

function stringToBytes(str){
  bytes=[];
  for(var i=0;i<str.length;i++){
    if(typeof i == "string")
      i=parseInt(i, 10);
    
    bytes[i]=str.charCodeAt(i);
  }
  return bytes;
}

function cypherText(bytes, key){
  var data=[];
  for (var i = 0; i < bytes.length; i++) {
    data[i]=BigInteger(bytes[i]).modPow(BigInteger(key[0]), BigInteger(key[1])).toString();
  }
  return data;
}

function decryptText(data, key){
  return bytesToString(cypherText(data, key));
}

function encryptText(text, key){
  return cypherText(stringToBytes(text), key);
}