# These are in-battle disaster effects caused by moves like Stormcall Blitz.
# Made by Luc-ker for Despair Challenge
module GameData
  class BattleDisaster
    attr_reader :id
    attr_reader :real_name
    attr_reader :animation

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
      @animation = hash[:animation]
    end

    # @return [String] the translated name of this battle disaster
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::BattleDisaster.register({
  :id   => :None,
  :name => _INTL("None")
})

GameData::BattleDisaster.register({
  :id        => :Thunderstorm,
  :name      => _INTL("Thunderstorm"),
  :animation => "ElectricTerrain"
})

GameData::BattleDisaster.register({
  :id        => :RagingTides,
  :name      => _INTL("Raging Tides"),
  :animation => "HeavyRain"
})

GameData::BattleDisaster.register({
  :id        => :Earthquake,
  :name      => _INTL("Earthquakes"),
  :animation => "ElectricTerrain"
})

GameData::BattleDisaster.register({
  :id        => :Heatwave,
  :name      => _INTL("Heatwave"),
  :animation => "Sun"
})
