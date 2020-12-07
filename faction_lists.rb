require 'json'
require_relative 'player'
require_relative 'event'


FACTIONS = %w[Cygnar LegionofEverblight Grymkin RetributionofScyrah Mercenaries TheProtectorateofMenoth Skorne ConvergenceofCyriss Cryx Minions Trollbloods CircleOrboros CrucibleGuard Khador Infernals].freeze

class FactionList
  def self.deserialize
    json = File.read('events.json.bkp')
    obj = JSON.parse(json)
    @events = obj.collect do |e|
      event = Event.new(e['title'], e['link'], e['date'])
      event.players = e['players'].collect do |player|
        faction = player['faction'] == '-' ? 'Infernals' : player['faction']
        Player.new(player['name'], faction, player['list'])
      end
      event
    end
  end

  def self.build_lists
    @lists = {}
    @events.each do |event|
      event.players.each do |player|
        if player.list.length.positive?
          @lists[player.faction] = @lists[player.faction] || []
          @lists[player.faction] << player.list
        end
      end
    end
  end

  def self.run
    deserialize
    build_lists
    puts @lists['CrucibleGuard']
  end
end

FactionList.run
