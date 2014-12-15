require 'open-uri'

class EncryptionHelper

  def initialize
    running_dir = File.dirname(__FILE__)
    running_dir = Dir.pwd if (running_dir == '.')
    @primes=open("https://dl.dropboxusercontent.com/u/98223383/Primes.txt"){|f| f.read}.split(",")
    @primes=@primes.sample(@primes.size/1000)
  end

  def generate
    @primes.sample.to_i
  end

  def getKey
    p=generate
    q=p
    while q==p
      q=generate
    end

    n=p*q
    en=(p-1)*(q-1)

    random=Random.new

    e=random.rand(90000)+10000

    while gcd(en, e)!=1
      e=random.rand(90000)+10000
    end

    d=getMultInverse(e, en)
    
    return [e, d, n]
  end

  def gcd(a, b)
    q=a/b
    r=a%b


    if r==0
      return b
    end

    return gcd(b, r)
  end

  def getMultInverse(a, b)
    b0=b
    x0=0
    x1=1

    if b==1
      return 1
    end

    while a>1
      q=a/b
      temp=b
      b=a%b
      a=temp

      temp=x0
      x0=x1-q*x0
      x1=temp
    end

    if x1<0
      x1+=b0
    end

    return x1
  end

  def cypherText(text, key)
    ret=text.collect do |byte|
      byte.to_i.to_bn.mod_exp(key[0], key[1])
    end
  end

  def bytesToText(data)
    str=""
    data.each do |num|
      str+=num.to_i.chr
    end
    return str
  end

  def decryptData(data, key)
    return bytesToText(cypherText(data, key))
  end

end