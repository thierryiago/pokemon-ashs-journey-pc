class PokeBattle_Battle
  #=============================================================================
  # Decrement effect counters
  #=============================================================================
  def pbEORCountDownBattlerEffect(priority,effect)
    priority.each do |b|
      next if b.fainted? || b.effects[effect]==0
      b.effects[effect] -= 1
      yield b if block_given? && b.effects[effect]==0
    end
  end

  def pbEORCountDownSideEffect(side,effect,msg)
    if @sides[side].effects[effect]>0
      @sides[side].effects[effect] -= 1
      pbDisplay(msg) if @sides[side].effects[effect]==0
    end
  end

  def pbEORCountDownFieldEffect(effect,msg)
    if @field.effects[effect]>0
      puts @field.effects[effect]
      @field.effects[effect] -= 1
      if @field.effects[effect]==0
        pbDisplay(msg)
        if effect==PBEffects::MagicRoom
          pbPriority(true).each { |b| b.pbItemTerrainStatBoostCheck }
        end
      end
    end
  end

  #=============================================================================
  # End Of Round weather
  #=============================================================================
  def pbEORWeather(priority)
    # NOTE: Primordial weather doesn't need to be checked here, because if it
    #       could wear off here, it will have worn off already.
    # Count down weather duration
    @field.weatherDuration -= 1 if @field.weatherDuration>0
    # Weather wears off
    if @field.weatherDuration==0
      case @field.weather
      when :Sun       then pbDisplay(_INTL("The sunlight faded."))
      when :Rain      then pbDisplay(_INTL("The rain stopped."))
      when :Sandstorm then pbDisplay(_INTL("The sandstorm subsided."))
      when :Hail      then pbDisplay(_INTL("The hail stopped."))
      when :ShadowSky then pbDisplay(_INTL("The shadow sky faded."))
      when :Fog       then pbDisplay(_INTL("The fog disappeared."))
      end
      @field.weather = :None
      # Check for form changes caused by the weather changing
      eachBattler { |b| b.pbCheckFormOnWeatherChange }
      eachBattler { |b| b.pbAbilityOnWeatherChange } # Sygna Challenge
      # Start up the default weather
      pbStartWeather(nil,@field.defaultWeather) if @field.defaultWeather != :None
      return if @field.weather == :None
    end
    # Weather continues
    weather_data = GameData::BattleWeather.try_get(@field.weather)
    pbCommonAnimation(weather_data.animation) if weather_data
    case @field.weather
#    when :Sun         then pbDisplay(_INTL("The sunlight is strong."))
#    when :Rain        then pbDisplay(_INTL("Rain continues to fall."))
    when :Sandstorm   then pbDisplay(_INTL("The sandstorm is raging."))
    when :Hail        then pbDisplay(_INTL("The hail is crashing down."))
#    when :HarshSun    then pbDisplay(_INTL("The sunlight is extremely harsh."))
#    when :HeavyRain   then pbDisplay(_INTL("It is raining heavily."))
#    when :StrongWinds then pbDisplay(_INTL("The wind is strong."))
    when :ShadowSky   then pbDisplay(_INTL("The shadow sky continues."))
    end
    # Effects due to weather
    curWeather = pbWeather
    priority.each do |b|
      # Weather-related abilities
      if b.abilityActive?
        BattleHandlers.triggerEORWeatherAbility(b.ability,curWeather,b,self)
        b.pbFaint if b.fainted?
      end
      # Weather damage
      # NOTE:
      case curWeather
      when :Sandstorm
        next if !b.takesSandstormDamage?
        pbDisplay(_INTL("{1} is buffeted by the sandstorm!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :Hail
        next if !b.takesHailDamage?
        pbDisplay(_INTL("{1} is buffeted by the hail!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      when :ShadowSky
        next if !b.takesShadowSkyDamage?
        pbDisplay(_INTL("{1} is hurt by the shadow sky!",b.pbThis))
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/16,false)
        b.pbItemHPHealCheck
        b.pbFaint if b.fainted?
      end
    end
  end

  #=============================================================================
  # End Of Round terrain
  #=============================================================================
  def pbEORTerrain
    # Count down terrain duration
    @field.terrainDuration -= 1 if @field.terrainDuration>0
    # Terrain wears off
    if @field.terrain != :None && @field.terrainDuration == 0
      case @field.terrain
      when :Electric
        pbDisplay(_INTL("The electric current disappeared from the battlefield!"))
      when :Grassy
        pbDisplay(_INTL("The grass disappeared from the battlefield!"))
      when :Misty
        pbDisplay(_INTL("The mist disappeared from the battlefield!"))
      when :Psychic
        pbDisplay(_INTL("The weirdness disappeared from the battlefield!"))
      end
      @field.terrain = :None
      eachBattler { |b| b.pbCheckFormOnTerrainChange } # Sygna Challenge
      # Start up the default terrain
      if @field.defaultTerrain != :None
        pbStartTerrain(nil, @field.defaultTerrain, false)
        eachBattler { |b| b.pbAbilityOnTerrainChange }
        eachBattler { |b| b.pbAbilityOnTerrainChange }
      end
      return if @field.terrain == :None
    end
    # Terrain continues
    terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
    pbCommonAnimation(terrain_data.animation) if terrain_data
    case @field.terrain
    when :Electric then pbDisplay(_INTL("An electric current is running across the battlefield."))
    when :Grassy   then pbDisplay(_INTL("Grass is covering the battlefield."))
    when :Misty    then pbDisplay(_INTL("Mist is swirling about the battlefield."))
    when :Psychic  then pbDisplay(_INTL("The battlefield is weird."))
    end
  end
  
  #=============================================================================
  # End Of Round zone (Sygna Challenge)
  #=============================================================================
  def pbEORZone
    # Count down zone duration
    @field.zoneDuration -= 1 if @field.zoneDuration>0
    # Zone wears off
    if @field.zone != :None && @field.zoneDuration == 0
      case @field.zone
      when :Normal
        pbDisplay(_INTL("The Normal Zone disappeared from the battlefield!"))
      when :Ice
        pbDisplay(_INTL("The arctic energy dissipated!"))
      when :Fighting
        pbDisplay(_INTL("The Fighting Zone disappeared from the battlefield!"))
      when :Poison
        pbDisplay(_INTL("The poisonous energy dissipated!"))
      when :Ground
        pbDisplay(_INTL("The battlefield became less earthen!"))
      when :Flying
        pbDisplay(_INTL("The Flying Zone disappeared from the battlefield!"))
      when :Bug
        pbDisplay(_INTL("The insects ran away from the battlefield!"))
      when :Rock
        pbDisplay(_INTL("The battlefield became less lithic!"))
      when :Ghost
        pbDisplay(_INTL("The battlefield is no longer haunted!"))
      when :Dragon
        pbDisplay(_INTL("The draconic energy disappeared from the battlefield!"))
      when :Dark
        pbDisplay(_INTL("The umbral energy disappeared from the battlefield!"))
      when :Steel
        pbDisplay(_INTL("The battlefield became less metallic!"))
      when :Fairy
        pbDisplay(_INTL("The whimsical energy disappeared from the battlefield!"))
      end
      @field.zone = :None
      # Start up the default zone
      eachBattler { |b| b.pbAbilityOnZoneChange }
      if @field.defaultZone != :None
        pbStartZone(nil, @field.defaultZone, false)
        eachBattler { |b| b.pbAbilityOnZoneChange }
      end
      return if @field.zone == :None
    end
    # Zone continues
    zone_data = GameData::BattleZone.try_get(@field.zone)
    pbCommonAnimation(zone_data.animation) if zone_data
    case @field.zone
    when :Normal   then pbDisplay(_INTL("A Normal Zone is active on the battlefield."))
    when :Ice      then pbDisplay(_INTL("The arctic energy remains on the battlefield."))
    when :Fighting then pbDisplay(_INTL("A Fighting Zone is active on the battlefield."))
    when :Poison   then pbDisplay(_INTL("The poisonous energy remains on the battlefield."))
    when :Ground   then pbDisplay(_INTL("The battlefield is earthen."))
    when :Flying   then pbDisplay(_INTL("A Flying Zone is active on the battlefield."))
    when :Bug      then pbDisplay(_INTL("The insects remain on the battlefield."))
    when :Rock     then pbDisplay(_INTL("The battlefield is lithic."))
    when :Ghost    then pbDisplay(_INTL("The battlefield is haunted."))
    when :Dragon   then pbDisplay(_INTL("The battlefield surges with draconic energy."))
    when :Dark     then pbDisplay(_INTL("Umbral energy surrounds the battlefield."))
    when :Steel    then pbDisplay(_INTL("The battlefield is metallic."))
    when :Fairy    then pbDisplay(_INTL("The battlefield surges with whimsical energy."))
    end
  end

  #=============================================================================
  # End Of Round shift distant battlers to middle positions
  #=============================================================================
  def pbEORShiftDistantBattlers
    # Move battlers around if none are near to each other
    # NOTE: This code assumes each side has a maximum of 3 battlers on it, and
    #       is not generalised to larger side sizes.
    if !singleBattle?
      swaps = []   # Each element is an array of two battler indices to swap
      for side in 0...2
        next if pbSideSize(side)==1   # Only battlers on sides of size 2+ need to move
        # Check if any battler on this side is near any battler on the other side
        anyNear = false
        eachSameSideBattler(side) do |b|
          eachOtherSideBattler(b) do |otherB|
            next if !nearBattlers?(otherB.index,b.index)
            anyNear = true
            break
          end
          break if anyNear
        end
        break if anyNear
        # No battlers on this side are near any battlers on the other side; try
        # to move them
        # NOTE: If we get to here (assuming both sides are of size 3 or less),
        #       there is definitely only 1 able battler on this side, so we
        #       don't need to worry about multiple battlers trying to move into
        #       the same position. If you add support for a side of size 4+,
        #       this code will need revising to account for that, as well as to
        #       add more complex code to ensure battlers will end up near each
        #       other.
        eachSameSideBattler(side) do |b|
          # Get the position to move to
          pos = -1
          case pbSideSize(side)
          when 2 then pos = [2,3,0,1][b.index]   # The unoccupied position
          when 3 then pos = (side==0) ? 2 : 3    # The centre position
          end
          next if pos<0
          # Can't move if the same trainer doesn't control both positions
          idxOwner = pbGetOwnerIndexFromBattlerIndex(b.index)
          next if pbGetOwnerIndexFromBattlerIndex(pos)!=idxOwner
          swaps.push([b.index,pos])
        end
      end
      # Move battlers around
      swaps.each do |pair|
        next if pbSideSize(pair[0])==2 && swaps.length>1
        next if !pbSwapBattlers(pair[0],pair[1])
        case pbSideSize(side)
        when 2
          pbDisplay(_INTL("{1} moved across!",@battlers[pair[1]].pbThis))
        when 3
          pbDisplay(_INTL("{1} moved to the center!",@battlers[pair[1]].pbThis))
        end
      end
    end
  end

  #=============================================================================
  # End Of Round phase
  #=============================================================================
  def pbEndOfRoundPhase
    PBDebug.log("")
    PBDebug.log("[End of round]")
    @endOfRound = true
    @scene.pbBeginEndOfRoundPhase
    pbCalculatePriority           # recalculate speeds
    priority = pbPriority(true)   # in order of fastest -> slowest speeds only
    # Weather
    pbEORWeather(priority)
    # Future Sight/Doom Desire
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::FutureSightCounter]==0
      pos.effects[PBEffects::FutureSightCounter] -= 1
      next if pos.effects[PBEffects::FutureSightCounter]>0
      next if !@battlers[idxPos] || @battlers[idxPos].fainted?   # No target
      moveUser = nil
      eachBattler do |b|
        next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
        next if b.pokemonIndex!=pos.effects[PBEffects::FutureSightUserPartyIndex]
        moveUser = b
        break
      end
      next if moveUser && moveUser.index==idxPos   # Target is the user
      if !moveUser   # User isn't in battle, get it from the party
        party = pbParty(pos.effects[PBEffects::FutureSightUserIndex])
        pkmn = party[pos.effects[PBEffects::FutureSightUserPartyIndex]]
        if pkmn && pkmn.able?
          moveUser = PokeBattle_Battler.new(self,pos.effects[PBEffects::FutureSightUserIndex])
          moveUser.pbInitDummyPokemon(pkmn,pos.effects[PBEffects::FutureSightUserPartyIndex])
        end
      end
      next if !moveUser   # User is fainted
      move = pos.effects[PBEffects::FutureSightMove]
      pbDisplay(_INTL("{1} took the {2} attack!",@battlers[idxPos].pbThis,
         GameData::Move.get(move).name))
      # NOTE: Future Sight failing against the target here doesn't count towards
      #       Stomping Tantrum.
      userLastMoveFailed = moveUser.lastMoveFailed
      @futureSight = true
      moveUser.pbUseMoveSimple(move,idxPos)
      @futureSight = false
      moveUser.lastMoveFailed = userLastMoveFailed
      @battlers[idxPos].pbFaint if @battlers[idxPos].fainted?
      pos.effects[PBEffects::FutureSightCounter]        = 0
      pos.resetFutureSightEffects
    end
    # Devil's Room (Despair Challenge)
    @positions.each_with_index do |pos,idxPos|
      idxPkmn = @battlers[idxPos]
      next if !pos || idxPkmn.fainted? || idxPkmn.effects[PBEffects::DevilsRoom] == -1
      idxPkmn.effects[PBEffects::DevilsRoom] -= 1
      pbDisplay(_INTL("{1} turns remain before the Devil's Room takes effect...",idxPkmn.effects[PBEffects::DevilsRoom]))
      if idxPkmn.effects[PBEffects::DevilsRoom] == 0 || (![:None, :Sun, :HarshSun].include?(@field.weather) && idxPkmn.effects[PBEffects::DevilsRoom]>-1)
        moveUser = nil
        eachBattler do |b|
          next if b.opposes?(pos.effects[PBEffects::FutureSightUserIndex])
          next if b.pokemonIndex!=pos.effects[PBEffects::FutureSightUserPartyIndex]
          moveUser = b
          break
        end
        move = pos.effects[PBEffects::FutureSightMove]
        if moveUser != nil
          pbDisplay(_INTL("{1} took the {2} attack!",@battlers[idxPos].pbThis,
            GameData::Move.get(move).name))
          @futureSight = true
          moveUser.pbUseMoveSimple(move,idxPos)
          @futureSight = false
        end
        idxPkmn.effects[PBEffects::MeanLook] = -1
        pbDisplay(_INTL("{1} was freed from the Devil's Room!",idxPkmn.pbThis))
        idxPkmn.attack,idxPkmn.spatk = idxPkmn.spatk,idxPkmn.attack
        pbDisplay(_INTL("{1} had its Attack and Special Attack stats reverted!",idxPkmn.pbThis))
        idxPkmn.effects[PBEffects::DevilsRoom] = -1
        pos.resetFutureSightEffects
      end
    end
    # Wish
    @positions.each_with_index do |pos,idxPos|
      next if !pos || pos.effects[PBEffects::Wish]==0
      pos.effects[PBEffects::Wish] -= 1
      next if pos.effects[PBEffects::Wish]>0
      next if !@battlers[idxPos] || !@battlers[idxPos].canHeal?
      wishMaker = pbThisEx(idxPos,pos.effects[PBEffects::WishMaker])
      @battlers[idxPos].pbRecoverHP(pos.effects[PBEffects::WishAmount])
      pbDisplay(_INTL("{1}'s wish came true!",wishMaker))
    end
    # Sea of Fire damage (Fire Pledge + Grass Pledge combination)
    curWeather = pbWeather
    for side in 0...2
      next if sides[side].effects[PBEffects::SeaOfFire]==0
      next if [:Rain, :HeavyRain].include?(curWeather)
      pbCommonAnimation("SeaOfFire") if side==0
      pbCommonAnimation("SeaOfFireOpp") if side==1
      priority.each do |b|
        next if b.opposes?(side)
        next if !b.takesIndirectDamage? || b.pbHasType?(:FIRE)
        oldHP = b.hp
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(b.totalhp/8,false)
        pbDisplay(_INTL("{1} is hurt by the sea of fire!",b.pbThis))
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Field Effect damage (True PWC)
    if ![:None, :Mist].include?(fieldEffect) && @field.effects[PBEffects::FieldOn]
      case fieldEffect
      when :Fire
        pbCommonAnimation("SeaOfFire")
        pbCommonAnimation("SeaOfFireOpp")
#        anim_name = GameData::Status.get(:BURN).animation
        type = :FIRE
        status = :BURN
        fieldName = "Burn Field"
      when :Water
#        anim_name = GameData::Moves.get(:SOAK).animation
        type = :WATER
        status = :SOAK
        fieldName = "Soak Field"
      when :Grass
#        anim_name = GameData::Moves.get(:FORESTSCURSE).animation
        type = :GRASS
        status = :FORESTSCURSE
        fieldName = "Vine Field"
      when :Electric
        anim_name = GameData::Status.get(:PARALYSIS).animation
        type = :ELECTRIC
        status = :PARALYSIS
        fieldName = "Zap Field"
      when :Rock
        pbCommonAnimation("Sandstorm")
        type = :ROCK
        fieldName = "Sand Field"
      when :Ice
        anim_name = GameData::Status.get(:FROZEN).animation
        type = :ICE
        status = :FROZEN
        fieldName = "Blizzard Field"
      end
      priority.each do |b|
        next if b.fainted?
        dmg = b.totalhp/8
        pbCommonAnimation(anim_name, b) if anim_name
        case fieldEffect
        when :Electric
          if b.hasActiveAbility?(:VOLTABSORB)
            pbShowAbilitySplash(b)
            b.pbRecoverHP(b.totalhp/8) if b.canHeal?
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
            else
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
            pbHideAbilitySplash(b)
            next
          elsif b.hasActiveAbility?(:MOTORDRIVE)
            pbShowAbilitySplash(b)
            if b.pbCanRaiseStatStage?(stat,target)
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                b.pbRaiseStatStage(:SPEED,1,b)
              else
                b.pbRaiseStatStageByCause(:SPEED,1,b,b.abilityName)
              end
            end
            pbHideAbilitySplash(b)
            next
          elsif b.hasActiveAbility?(:LIGHTNINGROD)
            pbShowAbilitySplash(b)
            if b.pbCanRaiseStatStage?(stat,target)
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                b.pbRaiseStatStage(:SPECIAL_ATTACK,1,b)
              else
                b.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,b,b.abilityName)
              end
            end
            pbHideAbilitySplash(b)
            next
          end
        when :Grass
          pbAnimation(:FORESTSCURSE, b, b)
          if b.hasActiveAbility?(:SAPSIPPER)
            pbShowAbilitySplash(b)
            b.pbRecoverHP(b.totalhp/8) if b.canHeal?
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
            else
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
            pbHideAbilitySplash(b)
            next
          end
        when :Fire
          if b.hasActiveAbility?(:FLASHFIRE)
            pbShowAbilitySplash(b)
            if !b.effects[PBEffects::FlashFire]
              b.effects[PBEffects::FlashFire] = true
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",
                 b.pbThis(true)))
              else
                battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
                 b.pbThis(true), b.abilityName))
              end
            else
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                battle.pbDisplay(_INTL("The {1} doesn't affect {2}...",
                 fieldName, b.pbThis(true)))
              else
                battle.pbDisplay(_INTL("{1}'s {2} made the {3} ineffective!",
                 b.pbThis, b.abilityName, fieldName))
              end
            end
            pbHideAbilitySplash(b)
            next
          end
          dmg /= 2 if b.hasActiveAbility?([:HEATPROOF, :THICKFAT, :WATERBUBBLE])
          dmg *= 2 if b.hasActiveAbility?([:DRYSKIN, :FLUFFY])
        when :Water
          pbAnimation(:WHIRLPOOL, b, b)
          if b.hasActiveAbility?([:WATERABSORB, :DRYSKIN])
            pbShowAbilitySplash(b)
            b.pbRecoverHP(b.totalhp/8) if b.canHeal?
            if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
            else
              pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
            end
            pbHideAbilitySplash(b)
            next
          elsif b.hasActiveAbility?(:STORMDRAIN)
            pbShowAbilitySplash(b)
            if b.pbCanRaiseStatStage?(stat,target)
              if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
                b.pbRaiseStatStage(:SPECIAL_ATTACK,1,b)
              else
                b.pbRaiseStatStageByCause(:SPECIAL_ATTACK,1,b,b.abilityName)
              end
            end
            pbHideAbilitySplash(b)
            next
          end
        when :Rock
          dmg /= 2 if b.hasActiveAbility?([:SANDSTREAM, :SANDRUSH, :SANDFORCE, :SANDVEIL])
        when :Ice
          dmg /= 2 if b.hasActiveAbility?(:THICKFAT)
        end
        next if !b.takesIndirectDamage? || b.pbHasType?(type)
        oldHP = b.hp
        @scene.pbDamageAnimation(b)
        b.pbReduceHP(dmg, false)
        pbDisplay(_INTL("{1} is hurt by the {2}!", b.pbThis, fieldName))
        if status
          msg = nil
          case status
          when :PARALYSIS
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              msg = _INTL("The {1} paralyzed {2}! It may be unable to move!",
               fieldName, user.pbThis(true))
            end
            b.pbParalyze(nil, msg) if b.pbCanParalyze?(nil, PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          when :BURN
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              msg = _INTL("The {1} burned {2}!",
               fieldName, user.pbThis(true))
            end
            b.pbBurn(nil, msg) if b.pbCanBurn?(nil, PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          when :FROZEN
            if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
              msg = _INTL("The {1} burned {2}!",
               fieldName, user.pbThis(true))
            end
            b.pbFreeze(msg) if b.pbCanFreeze?(nil, PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          when :SOAK
            pbDisplay(_INTL("The {1} soaked {2}, turning it into a Water type!",
             fieldName, b.pbThis(true)))
            b.pbChangeTypes(:WATER)
          when :FORESTSCURSE
            pbDisplay(_INTL("The {1} cursed {2}, turning it into a Grass type!",
             fieldName, b.pbThis(true)))
            b.effects[PBEffects::Type3] = :GRASS
          end
        end
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Status-curing effects/abilities and HP-healing items
    priority.each do |b|
      next if b.fainted?
      # Grassy Terrain (healing)
      if @field.terrain == :Grassy && b.affectedByTerrain? && b.canHeal?
        PBDebug.log("[Lingering effect] Grassy Terrain heals #{b.pbThis(true)}")
        b.pbRecoverHP(b.totalhp/16)
        pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      end
      # Healer, Hydration, Shed Skin
      BattleHandlers.triggerEORHealingAbility(b.ability,b,self) if b.abilityActive?
      # Passives which heal status conditions
      BattleHandlers.triggerEORHealingAbility(b.passive,b,self) if @passivesActive && b.passive
      # Black Sludge, Leftovers
      BattleHandlers.triggerEORHealingItem(b.item,b,self) if b.itemActive?
    end
    # Aqua Ring
    priority.each do |b|
      next if !b.effects[PBEffects::AquaRing]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("Aqua Ring restored {1}'s HP!",b.pbThis(true)))
    end
    # Ingrain
    priority.each do |b|
      next if !b.effects[PBEffects::Ingrain]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("{1} absorbed nutrients with its roots!",b.pbThis))
    end
    # Gradual Healing (Sygna Challenge)
    priority.each do |b|
      next if !b.effects[PBEffects::GradualHealing]
      next if !b.canHeal?
      hpGain = b.totalhp/16
      hpGain = (hpGain*1.3).floor if b.hasActiveItem?(:BIGROOT)
      b.pbRecoverHP(hpGain)
      pbDisplay(_INTL("{1} healed some of its HP!",b.pbThis))
    end
    # Leech Seed
    priority.each do |b|
      next if b.effects[PBEffects::LeechSeed]<0
      next if !b.takesIndirectDamage?
      recipient = @battlers[b.effects[PBEffects::LeechSeed]]
      next if !recipient || recipient.fainted?
      oldHP = b.hp
      oldHPRecipient = recipient.hp
      pbCommonAnimation("LeechSeed",recipient,b)
      hpLoss = b.pbReduceHP(b.totalhp/8)
      recipient.pbRecoverHPFromDrain(hpLoss,b,
         _INTL("{1}'s health is sapped by Leech Seed!",b.pbThis))
      recipient.pbAbilitiesOnDamageTaken(oldHPRecipient) if recipient.hp<oldHPRecipient
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
      recipient.pbFaint if recipient.fainted?
    end
    # Damage from Hyper Mode (Shadow Pokémon)
    priority.each do |b|
      next if !b.inHyperMode? || @choices[b.index][0]!=:UseMove
      hpLoss = b.totalhp/24
      @scene.pbDamageAnimation(b)
      b.pbReduceHP(hpLoss,false)
      pbDisplay(_INTL("The Hyper Mode attack hurts {1}!",b.pbThis(true)))
      b.pbFaint if b.fainted?
    end
    # Damage from poisoning
    priority.each do |b|
      next if b.fainted?
      next if b.status != :POISON
      if b.statusCount>0
        b.effects[PBEffects::Toxic] += 1
        b.effects[PBEffects::Toxic] = 15 if b.effects[PBEffects::Toxic]>15
      end
      if b.hasActiveAbility?(:POISONHEAL)
        if b.canHeal?
          anim_name = GameData::Status.get(:POISON).animation
          pbCommonAnimation(anim_name, b) if anim_name
          pbShowAbilitySplash(b)
          b.pbRecoverHP(b.totalhp/8)
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
          else
            pbDisplay(_INTL("{1}'s {2} restored its HP.",b.pbThis,b.abilityName))
          end
          pbHideAbilitySplash(b)
        end
      elsif b.takesIndirectDamage?
        oldHP = b.hp
        dmg = (b.statusCount==0) ? b.totalhp/8 : b.totalhp*b.effects[PBEffects::Toxic]/16
        b.pbContinueStatus { b.pbReduceHP(dmg,false) }
        b.pbItemHPHealCheck
        b.pbAbilitiesOnDamageTaken(oldHP)
        b.pbFaint if b.fainted?
      end
    end
    # Damage from burn
    priority.each do |b|
      next if b.status != :BURN || !b.takesIndirectDamage?
      oldHP = b.hp
      dmg = (Settings::MECHANICS_GENERATION >= 7) ? b.totalhp/16 : b.totalhp/8
      dmg = (dmg/2.0).round if b.hasActiveAbility?(:HEATPROOF)
      b.pbContinueStatus { b.pbReduceHP(dmg,false) }
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Damage from sleep (Nightmare)
    priority.each do |b|
      b.effects[PBEffects::Nightmare] = false if !b.asleep?
      next if !b.effects[PBEffects::Nightmare] || !b.takesIndirectDamage?
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/4)
      pbDisplay(_INTL("{1} is locked in a nightmare!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Curse
    priority.each do |b|
      next if !b.effects[PBEffects::Curse] || !b.takesIndirectDamage?
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/4)
      pbDisplay(_INTL("{1} is afflicted by the curse!",b.pbThis))
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
    # Octolock
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Octolock] < 0
      pbCommonAnimation("Octolock", b)
      b.pbLowerStatStage(:DEFENSE, 1, nil) if b.pbCanLowerStatStage?(:DEFENSE)
      b.pbLowerStatStage(:SPECIAL_DEFENSE, 1, nil, false) if b.pbCanLowerStatStage?(:SPECIAL_DEFENSE)
    end
    # Trapping attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Trapping]==0
      b.effects[PBEffects::Trapping] -= 1
      moveName = GameData::Move.get(b.effects[PBEffects::TrappingMove]).name
      if b.effects[PBEffects::Trapping]==0
        pbDisplay(_INTL("{1} was freed from {2}!",b.pbThis,moveName))
      else
        case b.effects[PBEffects::TrappingMove]
        when :BIND        then pbCommonAnimation("Bind", b)
        when :CLAMP       then pbCommonAnimation("Clamp", b)
        when :FIRESPIN    then pbCommonAnimation("FireSpin", b)
        when :MAGMASTORM  then pbCommonAnimation("MagmaStorm", b)
        when :SANDTOMB    then pbCommonAnimation("SandTomb", b)
        when :WRAP        then pbCommonAnimation("Wrap", b)
        when :INFESTATION then pbCommonAnimation("Infestation", b)
        when :SNAPTRAP    then pbCommonAnimation("SnapTrap",b)
        when :THUNDERCAGE then pbCommonAnimation("ThunderCage",b)
        else                   pbCommonAnimation("Wrap", b)
        end
        if b.takesIndirectDamage?
          hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/8 : b.totalhp/16
          if @battlers[b.effects[PBEffects::TrappingUser]].hasActiveItem?(:BINDINGBAND)
            hpLoss = (Settings::MECHANICS_GENERATION >= 6) ? b.totalhp/6 : b.totalhp/8
          end
          @scene.pbDamageAnimation(b)
          b.pbReduceHP(hpLoss,false)
          pbDisplay(_INTL("{1} is hurt by {2}!",b.pbThis,moveName))
          b.pbItemHPHealCheck
          # NOTE: No need to call pbAbilitiesOnDamageTaken as b can't switch out.
          b.pbFaint if b.fainted?
        end
      end
    end
    #---------------------------------------------------------------------------
    # ZUD - G-Max Vinelash, Wildfire, Cannonade, Volcalith
    #---------------------------------------------------------------------------
    _ZUD_EndOfRoundEffects(priority) if defined?(Settings::ZUD_COMPAT)
    #---------------------------------------------------------------------------
    # Taunt
    pbEORCountDownBattlerEffect(priority,PBEffects::Taunt) { |battler|
      pbDisplay(_INTL("{1}'s taunt wore off!",battler.pbThis))
    }
    # Encore
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::Encore]==0
      idxEncoreMove = b.pbEncoredMoveIndex
      if idxEncoreMove>=0
        b.effects[PBEffects::Encore] -= 1
        if b.effects[PBEffects::Encore]==0 || b.moves[idxEncoreMove].pp==0
          b.effects[PBEffects::Encore] = 0
          pbDisplay(_INTL("{1}'s encore ended!",b.pbThis))
        end
      else
        PBDebug.log("[End of effect] #{b.pbThis}'s encore ended (encored move no longer known)")
        b.effects[PBEffects::Encore]     = 0
        b.effects[PBEffects::EncoreMove] = nil
      end
    end
    # Disable/Cursed Body
    pbEORCountDownBattlerEffect(priority,PBEffects::Disable) { |battler|
      battler.effects[PBEffects::DisableMove] = nil
      pbDisplay(_INTL("{1} is no longer disabled!",battler.pbThis))
    }
    # Magnet Rise
    pbEORCountDownBattlerEffect(priority,PBEffects::MagnetRise) { |battler|
      pbDisplay(_INTL("{1}'s electromagnetism wore off!",battler.pbThis))
    }
    # Telekinesis
    pbEORCountDownBattlerEffect(priority,PBEffects::Telekinesis) { |battler|
      pbDisplay(_INTL("{1} was freed from the telekinesis!",battler.pbThis))
    }
    # Heal Block
    pbEORCountDownBattlerEffect(priority,PBEffects::HealBlock) { |battler|
      pbDisplay(_INTL("{1}'s Heal Block wore off!",battler.pbThis))
    }
    # Embargo
    pbEORCountDownBattlerEffect(priority,PBEffects::Embargo) { |battler|
      pbDisplay(_INTL("{1} can use items again!",battler.pbThis))
      battler.pbItemTerrainStatBoostCheck
    }
    # Yawn
    pbEORCountDownBattlerEffect(priority,PBEffects::Yawn) { |battler|
      if battler.pbCanSleepYawn?
        PBDebug.log("[Lingering effect] #{battler.pbThis} fell asleep because of Yawn")
        battler.pbSleep
      end
    }
    # Perish Song
    perishSongUsers = []
    priority.each do |b|
      next if b.fainted? || b.effects[PBEffects::PerishSong]==0
      b.effects[PBEffects::PerishSong] -= 1
      pbDisplay(_INTL("{1}'s perish count fell to {2}!",b.pbThis,b.effects[PBEffects::PerishSong]))
      if b.effects[PBEffects::PerishSong]==0
        perishSongUsers.push(b.effects[PBEffects::PerishSongUser])
        b.pbReduceHP(b.hp)
      end
      b.pbItemHPHealCheck
      b.pbFaint if b.fainted?
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all { |idxBattler| opposes?(idxBattler) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all { |idxBattler| !opposes?(idxBattler) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    # Check for end of battle
    if @decision>0
      pbGainExp
      return
    end
    for side in 0...2
      # Reflect
      pbEORCountDownSideEffect(side,PBEffects::Reflect,
         _INTL("{1}'s Reflect wore off!",@battlers[side].pbTeam))
      # Light Screen
      pbEORCountDownSideEffect(side,PBEffects::LightScreen,
         _INTL("{1}'s Light Screen wore off!",@battlers[side].pbTeam))
      # Safeguard
      pbEORCountDownSideEffect(side,PBEffects::Safeguard,
         _INTL("{1} is no longer protected by Safeguard!",@battlers[side].pbTeam))
      # Mist
      pbEORCountDownSideEffect(side,PBEffects::Mist,
         _INTL("{1} is no longer protected by mist!",@battlers[side].pbTeam))
      # Tailwind
      pbEORCountDownSideEffect(side,PBEffects::Tailwind,
         _INTL("{1}'s Tailwind petered out!",@battlers[side].pbTeam))
      # Lucky Chant
      pbEORCountDownSideEffect(side,PBEffects::LuckyChant,
         _INTL("{1}'s Lucky Chant wore off!",@battlers[side].pbTeam))
      # Pledge Rainbow
      pbEORCountDownSideEffect(side,PBEffects::Rainbow,
         _INTL("The rainbow on {1}'s side disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Sea of Fire
      pbEORCountDownSideEffect(side,PBEffects::SeaOfFire,
         _INTL("The sea of fire around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Pledge Swamp
      pbEORCountDownSideEffect(side,PBEffects::Swamp,
         _INTL("The swamp around {1} disappeared!",@battlers[side].pbTeam(true)))
      # Aurora Veil
      pbEORCountDownSideEffect(side,PBEffects::AuroraVeil,
         _INTL("{1}'s Aurora Veil wore off!",@battlers[side].pbTeam(true)))
    end
    # Trick Room
    pbEORCountDownFieldEffect(PBEffects::TrickRoom,
       _INTL("The twisted dimensions returned to normal!"))
    # Gravity
    pbEORCountDownFieldEffect(PBEffects::Gravity,
       _INTL("Gravity returned to normal!"))
    # Water Sport
    pbEORCountDownFieldEffect(PBEffects::WaterSportField,
       _INTL("The effects of Water Sport have faded."))
    # Mud Sport
    pbEORCountDownFieldEffect(PBEffects::MudSportField,
       _INTL("The effects of Mud Sport have faded."))
    # Wonder Room
    pbEORCountDownFieldEffect(PBEffects::WonderRoom,
       _INTL("Wonder Room wore off, and Defense and Sp. Def stats returned to normal!"))
    # Magic Room
    pbEORCountDownFieldEffect(PBEffects::MagicRoom,
       _INTL("Magic Room wore off, and held items' effects returned to normal!"))
    # End of terrains
    pbEORTerrain
    pbEORZone # Sygna Challenge
    priority.each do |b|
      next if b.fainted?
      # Hyper Mode (Shadow Pokémon)
      if b.inHyperMode?
        if pbRandom(100)<10
          b.pokemon.hyper_mode = false
          b.pokemon.adjustHeart(-50)
          pbDisplay(_INTL("{1} came to its senses!",b.pbThis))
        else
          pbDisplay(_INTL("{1} is in Hyper Mode!",b.pbThis))
        end
      end
      # Uproar
      if b.effects[PBEffects::Uproar]>0
        b.effects[PBEffects::Uproar] -= 1
        if b.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",b.pbThis))
        else
          pbDisplay(_INTL("{1} is making an uproar!",b.pbThis))
        end
      end
      # Slow Start's end message
      if b.effects[PBEffects::SlowStart]>0
        b.effects[PBEffects::SlowStart] -= 1
        if b.effects[PBEffects::SlowStart]==0
          pbDisplay(_INTL("{1} finally got its act together!",b.pbThis))
        end
      end
      # Love Train's end message (Despair Challenge)
      if b.effects[PBEffects::LoveTrain]>0
        b.effects[PBEffects::LoveTrain] -= 1
        if b.effects[PBEffects::LoveTrain]==0
          pbDisplay(_INTL(
            "{1}'s status condition and stat drop immunities ended!",b.pbThis))
        end
      end
      # Bad Dreams, Moody, Speed Boost
      BattleHandlers.triggerEOREffectAbility(b.ability,b,self) if b.abilityActive?
      # Flame Orb, Sticky Barb, Toxic Orb
      BattleHandlers.triggerEOREffectItem(b.item,b,self) if b.itemActive?
      # Harvest, Pickup, Ball Fetch
      BattleHandlers.triggerEORGainItemAbility(b.ability,b,self) if b.abilityActive?
    end
    pbGainExp
    return if @decision>0
    # Form checks
    priority.each { |b| b.pbCheckForm(true) }
    # Switch Pokémon in if possible
    pbEORSwitch
    return if @decision>0
    # In battles with at least one side of size 3+, move battlers around if none
    # are near to any foes
    pbEORShiftDistantBattlers
    # Try to make Trace work, check for end of primordial weather
    priority.each { |b| b.pbContinualAbilityChecks }
    # Reset/count down battler-specific effects (no messages)
    eachBattler do |b|
      b.effects[PBEffects::BanefulBunker]    = false
      b.effects[PBEffects::Charge]           -= 1 if b.effects[PBEffects::Charge]>0
      b.effects[PBEffects::Counter]          = -1
      b.effects[PBEffects::CounterTarget]    = -1
      b.effects[PBEffects::Electrify]        = false
      b.effects[PBEffects::Endure]           = false
      b.effects[PBEffects::FirstPledge]      = 0
      b.effects[PBEffects::Flinch]           = false
      b.effects[PBEffects::FocusPunch]       = false
      b.effects[PBEffects::FollowMe]         = 0
      b.effects[PBEffects::HelpingHand]      = false
      b.effects[PBEffects::HyperBeam]        -= 1 if b.effects[PBEffects::HyperBeam]>0
      b.effects[PBEffects::KingsShield]      = false
      b.effects[PBEffects::LaserFocus]       -= 1 if b.effects[PBEffects::LaserFocus]>0
      if b.effects[PBEffects::LockOn]>0   # Also Mind Reader
        b.effects[PBEffects::LockOn]         -= 1
        b.effects[PBEffects::LockOnPos]      = -1 if b.effects[PBEffects::LockOn]==0
      end
      b.effects[PBEffects::MagicBounce]      = false
      b.effects[PBEffects::MagicCoat]        = false
      b.effects[PBEffects::MirrorCoat]       = -1
      b.effects[PBEffects::MirrorCoatTarget] = -1
      b.effects[PBEffects::Powder]           = false
      b.effects[PBEffects::Prankster]        = false
      b.effects[PBEffects::PriorityAbility]  = false
      b.effects[PBEffects::PriorityItem]     = false
      b.effects[PBEffects::Protect]          = false
      b.effects[PBEffects::RagePowder]       = false
      b.effects[PBEffects::Roost]            = false
      b.effects[PBEffects::Snatch]           = 0
      b.effects[PBEffects::SpikyShield]      = false
      b.effects[PBEffects::Spotlight]        = 0
      b.effects[PBEffects::ThroatChop]       -= 1 if b.effects[PBEffects::ThroatChop]>0
      b.effects[PBEffects::Obstruct]         = false
      # Despair Challenge
      b.effects[PBEffects::ConquerorsAura]   -= 1 if b.effects[PBEffects::ConquerorsAura]>0
      b.effects[PBEffects::PhysNeg]          = false
      b.effects[PBEffects::SpecNeg]          = false
      b.effects[PBEffects::StatusNeg]        = false
      # Sygna Challenge
      b.effects[PBEffects::SureHit]          -= 1 if b.effects[PBEffects::SureHit]>0
      b.effects[PBEffects::Vigilance]        -= 1 if b.effects[PBEffects::Vigilance]>0
      b.lastHPLost                           = 0
      b.lastHPLostFromFoe                    = 0
      b.tookDamage                           = false
      b.tookPhysicalHit                      = false
      b.statsRaised                          = false
      b.statsLowered                         = false
      b.lastRoundMoveFailed                  = b.lastMoveFailed
      b.lastAttacker.clear
      b.lastFoeAttacker.clear
    end
    # Reset/count down side-specific effects (no messages)
    for side in 0...2
      @sides[side].effects[PBEffects::CraftyShield]         = false
      if !@sides[side].effects[PBEffects::EchoedVoiceUsed]
        @sides[side].effects[PBEffects::EchoedVoiceCounter] = 0
      end
      @sides[side].effects[PBEffects::EchoedVoiceUsed]      = false
      @sides[side].effects[PBEffects::MatBlock]             = false
      @sides[side].effects[PBEffects::QuickGuard]           = false
      @sides[side].effects[PBEffects::Round]                = false
      @sides[side].effects[PBEffects::WideGuard]            = false
    end
    # Reset/count down field-specific effects (no messages)
    @field.effects[PBEffects::IonDeluge]   = false
    @field.effects[PBEffects::FairyLock]   -= 1 if @field.effects[PBEffects::FairyLock]>0
    @field.effects[PBEffects::FusionBolt]  = false
    @field.effects[PBEffects::FusionFlare] = false
    # Neutralizing Gas
    pbCheckNeutralizingGas
    @endOfRound = false
  end


  def pbCheckNeutralizingGas(battler = nil)
    return if !@field.effects[PBEffects::NeutralizingGas]
    return if battler && (battler.ability == :NEUTRALIZINGGAS ||
		battler.effects[PBEffects::GastroAcid])
    hasabil = false
    eachBattler do |b|
	    next if battler && b.index == battler.index
      # neutralizing gas can be blocked with gastro acid, ending the effect.
      if b.ability == :NEUTRALIZINGGAS && !b.effects[PBEffects::GastroAcid]
        hasabil = true; break
      end
    end
    if !hasabil
      @field.effects[PBEffects::NeutralizingGas] = false
      pbPriority(true).each { |b|
	      next if battler && b.index == battler.index
	      b.pbEffectsOnSwitchIn
      }
    end
  end
end
