class User
  attr_accessor :ws
  attr_reader :name, :key

  def initialize(ws, name, key)
    @ws=ws
    @name=name
    @key=key
  end
end