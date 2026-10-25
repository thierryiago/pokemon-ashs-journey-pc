begin
  class PokeBattle_ActiveField
    attr_accessor :effects
    attr_accessor :defaultWeather
    attr_accessor :weather
    attr_accessor :weatherDuration
    attr_accessor :defaultTerrain
    attr_accessor :terrain
    attr_accessor :terrainDuration
    # Zone for Sygna Challenge
    attr_accessor :defaultZone
    attr_accessor :zone
    attr_accessor :zoneDuration
    # Disasters for Despair Challenge
    attr_accessor :disasters
    
    def initialize
      @effects = []
      @effects[PBEffects::AmuletCoin]      = false
      @effects[PBEffects::FairyLock]       = 0
      @effects[PBEffects::FusionBolt]      = false
      @effects[PBEffects::FusionFlare]     = false
      @effects[PBEffects::Gravity]         = 0
      @effects[PBEffects::HappyHour]       = false
      @effects[PBEffects::IonDeluge]       = false
      @effects[PBEffects::MagicRoom]       = 0
      @effects[PBEffects::MudSportField]   = 0
      @effects[PBEffects::PayDay]          = 0
      @effects[PBEffects::TrickRoom]       = 0
      @effects[PBEffects::WaterSportField] = 0
      @effects[PBEffects::WonderRoom]      = 0
      @defaultWeather  = :None
      @weather         = :None
      @weatherDuration = 0
      @defaultTerrain  = :None
      @terrain         = :None
      @terrainDuration = 0
      # Zone for Sygna Challenge
      @defaultZone     = :None
      @zone            = :None
      @zoneDuration    = 0
      # Disasters for Despair Challenge
      @disasters       = []
      # Field effects for True PWC
      @effects[PBEffects::FieldOn]         = false
    end
  end



  class PokeBattle_ActiveSide
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::AuroraVeil]         = 0
      @effects[PBEffects::CraftyShield]       = false
      @effects[PBEffects::EchoedVoiceCounter] = 0
      @effects[PBEffects::EchoedVoiceUsed]    = false
      @effects[PBEffects::LastRoundFainted]   = -1
      @effects[PBEffects::LightScreen]        = 0
      @effects[PBEffects::LuckyChant]         = 0
      @effects[PBEffects::MatBlock]           = false
      @effects[PBEffects::Mist]               = 0
      @effects[PBEffects::QuickGuard]         = false
      @effects[PBEffects::Rainbow]            = 0
      @effects[PBEffects::Reflect]            = 0
      @effects[PBEffects::Round]              = false
      @effects[PBEffects::Safeguard]          = 0
      @effects[PBEffects::SeaOfFire]          = 0
      @effects[PBEffects::Spikes]             = 0
      @effects[PBEffects::StealthRock]        = false
      @effects[PBEffects::StickyWeb]          = false
      @effects[PBEffects::Swamp]              = 0
      @effects[PBEffects::Tailwind]           = 0
      @effects[PBEffects::ToxicSpikes]        = 0
      @effects[PBEffects::WideGuard]          = false
      @effects[PBEffects::StickyWebUser]      = -1 
      @effects[PBEffects::MadeInHeaven]       = 0
      @effects[PBEffects::DamageIncrease]     = 1
      @effects[PBEffects::DamageReduction]    = 1
      @effects[PBEffects::SyncEnergy]         = 0
      @effects[PBEffects::PhysDmgIncrease]    = 1
      @effects[PBEffects::PhysDmgReduction]   = 1
      @effects[PBEffects::SpecDmgIncrease]    = 1
      @effects[PBEffects::SpecDmgReduction]   = 1
    end
  end



  class PokeBattle_ActivePosition
    attr_accessor :effects

    def initialize
      @effects = []
      @effects[PBEffects::FutureSightCounter]        = 0
      @effects[PBEffects::FutureSightMove]           = nil
      @effects[PBEffects::FutureSightUserIndex]      = -1
      @effects[PBEffects::FutureSightUserPartyIndex] = -1
      @effects[PBEffects::HealingWish]               = false
      @effects[PBEffects::LunarDance]                = false
      @effects[PBEffects::Wish]                      = 0
      @effects[PBEffects::WishAmount]                = 0
      @effects[PBEffects::WishMaker]                 = -1
    end
    
    def resetFutureSightEffects
      @effects[PBEffects::FutureSightMove]           = nil
      @effects[PBEffects::FutureSightUserIndex]      = -1
      @effects[PBEffects::FutureSightUserPartyIndex] = -1
    end
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end
