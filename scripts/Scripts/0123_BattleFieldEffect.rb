module GameData
  class BattleFieldEffect
    attr_reader :id
    attr_reader :real_name
    attr_reader :backdrop_name

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id        = hash[:id]
      @real_name = hash[:name] || "Unnamed"
      @backdrop_name = hash[:backdrop] || "indoor1"
    end

    # @return [String] the translated name of this battle field effect
    def name
      return _INTL(@real_name)
    end

    # @return [String] the name of the backdrop this field effect uses
    def backdrop
      return _INTL(@backdrop_name)
    end
  end
end

#===============================================================================

GameData::BattleFieldEffect.register({
  :id   => :None,
  :name => _INTL("None"),
  :backdrop => _INTL("indoor1")
})

GameData::BattleFieldEffect.register({
  :id        => :Fire,
  :name      => _INTL("Fire"),
  :backdrop => _INTL("elite3")
})

GameData::BattleFieldEffect.register({
  :id        => :Water,
  :name      => _INTL("Water"),
  :backdrop => _INTL("water")
})

GameData::BattleFieldEffect.register({
  :id        => :Rock,
  :name      => _INTL("Rock"),
  :backdrop => _INTL("rocky")
})

GameData::BattleFieldEffect.register({
  :id        => :Ice,
  :name      => _INTL("Ice"),
  :backdrop => _INTL("snow")
})

GameData::BattleFieldEffect.register({
  :id        => :Electric,
  :name      => _INTL("Electric"),
  :backdrop => _INTL("champion1")
})

GameData::BattleFieldEffect.register({
  :id        => :Grass,
  :name      => _INTL("Grass"),
  :backdrop => _INTL("forest")
})

GameData::BattleFieldEffect.register({
  :id        => :Mist,
  :name      => _INTL("Mist"),
  :backdrop => _INTL("elite8")
})

GameData::BattleFieldEffect.register({
  :id        => :Psychic,
  :name      => _INTL("Psychic"),
  :backdrop => _INTL("elite4")
})
