class Player
  attr_reader :name, :faction, :list

  def initialize(name, faction, list)
    @name = name
    @faction = faction
    @list = list
  end

  def to_hash
    {
      name: @name,
      faction: @faction,
      list: @list
    }
  end

  def to_json(*options)
    to_hash.to_json(*options)
  end
end
