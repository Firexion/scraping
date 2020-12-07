class Event
  attr_reader :title, :link, :date
  attr_accessor :players

  def initialize(title, link, date)
    @title = title
    @link = link
    @date = date
    @players = []
  end

  def to_hash(options = {})
    {
      title: @title,
      link: @link,
      date: @date,
      players: @players.map(&:to_hash)
    }
  end

  def to_json(*options)
    to_hash(*options).to_json(*options)
  end
end
