# These are in-battle zone effects caused by moves like Fairy Wish.
# Made by Luc-ker for Sygna Challenge
module GameData
  class BattleZone
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

    # @return [String] the translated name of this battle zone
    def name
      return _INTL(@real_name)
    end
  end
end

#===============================================================================

GameData::BattleZone.register({
  :id   => :None,
  :name => _INTL("None")
})

GameData::BattleZone.register({
  :id        => :Normal,
  :name      => _INTL("Normal"),
  :animation => "NormalZone"
})

GameData::BattleZone.register({
  :id        => :Ice,
  :name      => _INTL("Ice"),
  :animation => "Hail"
})

GameData::BattleZone.register({
  :id        => :Fighting,
  :name      => _INTL("Fighting"),
  :animation => "FightingZone"
})

GameData::BattleZone.register({
  :id        => :Poison,
  :name      => _INTL("Poison"),
  :animation => "PoisonZone"
})

GameData::BattleZone.register({
  :id        => :Ground,
  :name      => _INTL("Ground"),
  :animation => "Sandstorm"
})

GameData::BattleZone.register({
  :id        => :Flying,
  :name      => _INTL("Flying"),
  :animation => "StrongWinds"
})

GameData::BattleZone.register({
  :id        => :Bug,
  :name      => _INTL("Bug"),
  :animation => "BugZone"
})

GameData::BattleZone.register({
  :id        => :Rock,
  :name      => _INTL("Rock"),
  :animation => "Sandstorm"
})

GameData::BattleZone.register({
  :id        => :Ghost,
  :name      => _INTL("Ghost"),
  :animation => "ShadowSky"
})

GameData::BattleZone.register({
  :id        => :Dragon,
  :name      => _INTL("Dragon"),
  :animation => "DragonZone"
})

GameData::BattleZone.register({
  :id        => :Dark,
  :name      => _INTL("Dark"),
  :animation => "Fog"
})

GameData::BattleZone.register({
  :id        => :Steel,
  :name      => _INTL("Steel"),
  :animation => "SteelZone"
})

GameData::BattleZone.register({
  :id        => :Fairy,
  :name      => _INTL("Fairy"),
  :animation => "MistyTerrain"
})
