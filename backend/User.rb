class User
  attr_reader :ws, :name, :key

  def initialize(ws, name, key)
    @ws=ws
    @name=name
    @key=key
  end
end