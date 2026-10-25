#===============================================================================
# SpeedCalcAbility handlers
#===============================================================================

BattleHandlers::SpeedCalcAbility.add(:CHLOROPHYLL,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sun, :HarshSun].include?(battler.battle.pbWeather) if !battler.hasUtilityUmbrella?
  }
)

BattleHandlers::SpeedCalcAbility.add(:QUICKFEET,
  proc { |ability,battler,mult|
    next mult*1.5 if battler.pbHasAnyStatus?
  }
)

BattleHandlers::SpeedCalcAbility.add(:SANDRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Sandstorm].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLOWSTART,
  proc { |ability,battler,mult|
    next mult/2 if battler.effects[PBEffects::SlowStart]>0
  }
)

BattleHandlers::SpeedCalcAbility.add(:SLUSHRUSH,
  proc { |ability,battler,mult|
    next mult * 2 if [:Hail].include?(battler.battle.pbWeather)
  }
)

BattleHandlers::SpeedCalcAbility.add(:SURGESURFER,
  proc { |ability,battler,mult|
    next mult*2 if battler.battle.field.terrain == :Electric
  }
)

BattleHandlers::SpeedCalcAbility.add(:SWIFTSWIM,
  proc { |ability,battler,mult|
    next mult * 2 if [:Rain, :HeavyRain].include?(battler.battle.pbWeather) && !battler.hasUtilityUmbrella?
  }
)

BattleHandlers::SpeedCalcAbility.add(:UNBURDEN,
  proc { |ability,battler,mult|
    next mult*2 if battler.effects[PBEffects::Unburden] && !battler.item && battler.abilityActive?
  }
)

#===============================================================================
# WeightCalcAbility handlers
#===============================================================================

BattleHandlers::WeightCalcAbility.add(:HEAVYMETAL,
  proc { |ability,battler,w|
    next w*2
  }
)

BattleHandlers::WeightCalcAbility.add(:LIGHTMETAL,
  proc { |ability,battler,w|
    next [w/2,1].max
  }
)

#===============================================================================
# AbilityOnHPDroppedBelowHalf handlers
#===============================================================================

BattleHandlers::AbilityOnHPDroppedBelowHalf.add(:EMERGENCYEXIT,
  proc { |ability,battler,battle|
    next false if battler.effects[PBEffects::SkyDrop]>=0 || battler.inTwoTurnAttack?("0CE")   # Sky Drop
    # In wild battles
    if battle.wildBattle?
      next false if battler.opposes? && battle.pbSideBattlerCount(battler.index)>1
      next false if !battle.pbCanRun?(battler.index)
      battle.pbShowAbilitySplash(battler,true)
      battle.pbHideAbilitySplash(battler)
      pbSEPlay("Battle flee")
      battle.pbDisplay(_INTL("{1} fled from battle!",battler.pbThis))
      battle.decision = 3   # Escaped
      next true
    end
    # In trainer battles
    next false if battle.pbAllFainted?(battler.idxOpposingSide)
    next false if !battle.pbCanSwitch?(battler.index)   # Battler can't switch out
    next false if !battle.pbCanChooseNonActive?(battler.index)   # No Pokémon can switch in
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} activated!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("{1} went back to {2}!",
       battler.pbThis,battle.pbGetOwnerName(battler.index)))
    if battle.endOfRound   # Just switch out
      battle.scene.pbRecall(battler.index) if !battler.fainted?
      battler.pbAbilitiesOnSwitchOut   # Inc. primordial weather check
      next true
    end
    newPkmn = battle.pbGetReplacementPokemonIndex(battler.index)   # Owner chooses
    next false if newPkmn<0   # Shouldn't ever do this
    battle.pbRecallAndReplace(battler.index,newPkmn)
    battle.pbClearChoice(battler.index)   # Replacement Pokémon does nothing this round
    next true
  }
)

BattleHandlers::AbilityOnHPDroppedBelowHalf.copy(:EMERGENCYEXIT,:WIMPOUT)

#===============================================================================
# StatusCheckAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusCheckAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next false if !battler.isSpecies?(:KOMALA)
    next true if status.nil? || status == :SLEEP
  }
)

#===============================================================================
# StatusImmunityAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAbility.add(:IMMUNITY,
  proc { |ability,battler,status|
    next true if status == :POISON
  }
)

BattleHandlers::StatusImmunityAbility.copy(:IMMUNITY,:PASTELVEIL)

BattleHandlers::StatusImmunityAbility.add(:INSOMNIA,
  proc { |ability,battler,status|
    next true if status == :SLEEP
  }
)

BattleHandlers::StatusImmunityAbility.copy(:INSOMNIA,:SWEETVEIL,:VITALSPIRIT)

BattleHandlers::StatusImmunityAbility.add(:LEAFGUARD,
  proc { |ability,battler,status|
    next true if [:Sun, :HarshSun].include?(battler.battle.pbWeather) && !battler.hasUtilityUmbrella?
  }
)

BattleHandlers::StatusImmunityAbility.add(:LIMBER,
  proc { |ability,battler,status|
    next true if status == :PARALYSIS
  }
)

BattleHandlers::StatusImmunityAbility.add(:MAGMAARMOR,
  proc { |ability,battler,status|
    next true if status == :FROZEN
  }
)

BattleHandlers::StatusImmunityAbility.add(:WATERVEIL,
  proc { |ability,battler,status|
    next true if status == :BURN
  }
)

BattleHandlers::StatusImmunityAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatusImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:COMATOSE,
  proc { |ability,battler,status|
    next true if battler.isSpecies?(:KOMALA)
  }
)

BattleHandlers::StatusImmunityAbilityNonIgnorable.add(:SHIELDSDOWN,
  proc { |ability,battler,status|
    next true if battler.isSpecies?(:MINIOR) && battler.form<7
  }
)

#===============================================================================
# StatusImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatusImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,battler,status|
    next true if battler.pbHasType?(:GRASS)
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:SWEETVEIL,
  proc { |ability,battler,status|
    next true if status == :SLEEP
  }
)

BattleHandlers::StatusImmunityAllyAbility.add(:PASTELVEIL,
  proc { |ability,battler,status|
    next true if status == :POISON
  }
)

#===============================================================================
# AbilityOnStatusInflicted handlers
#===============================================================================

BattleHandlers::AbilityOnStatusInflicted.add(:SYNCHRONIZE,
  proc { |ability,battler,user,status|
    next if !user || user.index==battler.index
    case status
    when :POISON
      if user.pbCanPoisonSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} poisoned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbPoison(nil,msg,(battler.statusCount>0))
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :BURN
      if user.pbCanBurnSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} burned {3}!",battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbBurn(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    when :PARALYSIS
      if user.pbCanParalyzeSynchronize?(battler)
        battler.battle.pbShowAbilitySplash(battler)
        msg = nil
        if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
             battler.pbThis,battler.abilityName,user.pbThis(true))
        end
        user.pbParalyze(nil,msg)
        battler.battle.pbHideAbilitySplash(battler)
      end
    end
  }
)

#===============================================================================
# StatusCureAbility handlers
#===============================================================================

BattleHandlers::StatusCureAbility.add(:IMMUNITY,
  proc { |ability,battler|
    next if battler.status != :POISON
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its poisoning!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:IMMUNITY,:PASTELVEIL)

BattleHandlers::StatusCureAbility.add(:INSOMNIA,
  proc { |ability,battler|
    next if battler.status != :SLEEP
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:INSOMNIA,:VITALSPIRIT)

BattleHandlers::StatusCureAbility.add(:LIMBER,
  proc { |ability,battler|
    next if battler.status != :PARALYSIS
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:MAGMAARMOR,
  proc { |ability,battler|
    next if battler.status != :FROZEN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OBLIVIOUS,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Attract]<0 &&
            (battler.effects[PBEffects::Taunt]==0 || Settings::MECHANICS_GENERATION <= 5)
    battler.battle.pbShowAbilitySplash(battler)
    if battler.effects[PBEffects::Attract]>=0
      battler.pbCureAttract
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1} got over its infatuation.",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} cured its infatuation status!",
           battler.pbThis,battler.abilityName))
      end
    end
    if battler.effects[PBEffects::Taunt]>0 && Settings::MECHANICS_GENERATION >= 6
      battler.effects[PBEffects::Taunt] = 0
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battler.battle.pbDisplay(_INTL("{1}'s Taunt wore off!",battler.pbThis))
      else
        battler.battle.pbDisplay(_INTL("{1}'s {2} made its taunt wear off!",
           battler.pbThis,battler.abilityName))
      end
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:OWNTEMPO,
  proc { |ability,battler|
    next if battler.effects[PBEffects::Confusion]==0
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureConfusion
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1} snapped out of its confusion.",battler.pbThis))
    else
      battler.battle.pbDisplay(_INTL("{1}'s {2} snapped it out of its confusion!",
         battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.add(:WATERVEIL,
  proc { |ability,battler|
    next if battler.status != :BURN
    battler.battle.pbShowAbilitySplash(battler)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battler.battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
    end
    battler.battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusCureAbility.copy(:WATERVEIL,:WATERBUBBLE)

#===============================================================================
# StatLossImmunityAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbility.add(:BIGPECKS,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:CLEARBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:WHITESMOKE)

BattleHandlers::StatLossImmunityAbility.add(:FLOWERVEIL,
  proc { |ability,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:HYPERCUTTER,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:ATTACK
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:KEENEYE,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:ACCURACY
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::StatLossImmunityAbilityNonIgnorable.add(:FULLMETALBODY,
  proc { |ability,battler,stat,battle,showMessages|
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# StatLossImmunityAllyAbility handlers
#===============================================================================

BattleHandlers::StatLossImmunityAllyAbility.add(:FLOWERVEIL,
  proc { |ability,bearer,battler,stat,battle,showMessages|
    next false if !battler.pbHasType?(:GRASS)
    if showMessages
      battle.pbShowAbilitySplash(bearer)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s stat loss!",
           bearer.pbThis,bearer.abilityName,battler.pbThis(true)))
      end
      battle.pbHideAbilitySplash(bearer)
    end
    next true
  }
)

#===============================================================================
# AbilityOnStatGain handlers
#===============================================================================

# There aren't any!

#===============================================================================
# TargetAbilityOnStatLoss handlers
#===============================================================================

BattleHandlers::TargetAbilityOnStatLoss.add(:COMPETITIVE,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,battler)
  }
)

BattleHandlers::TargetAbilityOnStatLoss.add(:DEFIANT,
  proc { |ability,battler,stat,user|
    next if user && !user.opposes?(battler)
    battler.pbRaiseStatStageByAbility(:ATTACK,2,battler)
  }
)

#===============================================================================
# PriorityChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityChangeAbility.add(:GALEWINGS,
  proc { |ability,battler,move,pri|
    next pri+1 if battler.hp==battler.totalhp && move.type == :FLYING
  }
)

BattleHandlers::PriorityChangeAbility.add(:PRANKSTER,
  proc { |ability,battler,move,pri|
    if move.statusMove?
      battler.effects[PBEffects::Prankster] = true
      next pri+1
    end
  }
)

BattleHandlers::PriorityChangeAbility.add(:TRIAGE,
  proc { |ability,battler,move,pri|
    next pri+3 if move.healingMove?
  }
)

#===============================================================================
# PriorityBracketChangeAbility handlers
#===============================================================================

BattleHandlers::PriorityBracketChangeAbility.add(:STALL,
  proc { |ability,battler,subPri,battle|
    next -1 if subPri==0
  }
)

BattleHandlers::PriorityBracketChangeAbility.add(:QUICKDRAW,
  proc { |ability,battler,subPri,battle|
    next 1 if subPri<1 && battle.pbRandom(10)<3
  }
)

#===============================================================================
# PriorityBracketUseAbility handlers
#===============================================================================

BattleHandlers::PriorityBracketUseAbility.add(:QUICKDRAW,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{2} made {1} move faster!",battler.pbThis,battler.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# AbilityOnFlinch handlers
#===============================================================================

BattleHandlers::AbilityOnFlinch.add(:STEADFAST,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:SPEED,1,battler)
  }
)

#===============================================================================
# MoveBlockingAbility handlers
#===============================================================================

BattleHandlers::MoveBlockingAbility.add(:DAZZLING,
  proc { |ability,bearer,user,targets,move,battle|
    next false if battle.choices[user.index][4]<=0
    next false if !bearer.opposes?(user)
    ret = false
    targets.each do |b|
      next if !b.opposes?(user)
      ret = true
    end
    next ret
  }
)

BattleHandlers::MoveBlockingAbility.copy(:DAZZLING,:QUEENLYMAJESTY)

#===============================================================================
# MoveImmunityTargetAbility handlers
#===============================================================================

BattleHandlers::MoveImmunityTargetAbility.add(:BULLETPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.bombMove?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,type,battle|
    next false if user.index==target.index
    next false if type != :FIRE
    battle.pbShowAbilitySplash(target)
    if !target.effects[PBEffects::FlashFire]
      target.effects[PBEffects::FlashFire] = true
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose!",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("The power of {1}'s Fire-type moves rose because of its {2}!",
           target.pbThis(true),target.abilityName))
      end
    else
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      else
        battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           target.pbThis,target.abilityName,move.name))
      end
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:MOTORDRIVE,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:ELECTRIC,:SPEED,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SAPSIPPER,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:GRASS,:ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:SOUNDPROOF,
  proc { |ability,user,target,move,type,battle|
    next false if !move.soundMove?
    next false if Settings::MECHANICS_GENERATION >= 8 && user.index == target.index
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,target.abilityName,move.name))
    end
    battle.pbHideAbilitySplash(target)
    next true

  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:STORMDRAIN,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityStatAbility(user,target,move,type,:WATER,:SPECIAL_ATTACK,1,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:TELEPATHY,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if user.index==target.index || target.opposes?(user)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon!",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoids attacks by its ally Pokémon with {2}!",
         target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:VOLTABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:ELECTRIC,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:WATERABSORB,
  proc { |ability,user,target,move,type,battle|
    next pbBattleMoveImmunityHealAbility(user,target,move,type,:WATER,battle)
  }
)

BattleHandlers::MoveImmunityTargetAbility.copy(:WATERABSORB,:DRYSKIN)

BattleHandlers::MoveImmunityTargetAbility.add(:WONDERGUARD,
  proc { |ability,user,target,move,type,battle|
    next false if move.statusMove?
    next false if !type || Effectiveness.super_effective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1} avoided damage with {2}!",target.pbThis,target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
    next true
  }
)

#===============================================================================
# MoveBaseTypeModifierAbility handlers
#===============================================================================

BattleHandlers::MoveBaseTypeModifierAbility.add(:AERILATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:FLYING)
    move.powerBoost = true
    next :FLYING
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:GALVANIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:ELECTRIC)
    move.powerBoost = true
    next :ELECTRIC
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:LIQUIDVOICE,
  proc { |ability,user,move,type|
    next :WATER if GameData::Type.exists?(:WATER) && move.soundMove?
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NORMALIZE,
  proc { |ability,user,move,type|
    next if !GameData::Type.exists?(:NORMAL)
    move.powerBoost = true if Settings::MECHANICS_GENERATION >= 7
    next :NORMAL
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:PIXILATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:FAIRY)
    move.powerBoost = true
    next :FAIRY
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:REFRIGERATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:ICE)
    move.powerBoost = true
    next :ICE
  }
)

#===============================================================================
# AccuracyCalcUserAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAbility.add(:COMPOUNDEYES,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.3
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:HUSTLE,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 0.8 if move.physicalMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:KEENEYE,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_stage] = 0 if mods[:evasion_stage] > 0 && Settings::MECHANICS_GENERATION >= 6
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

#===============================================================================
# AccuracyCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcUserAllyAbility.add(:VICTORYSTAR,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.1
  }
)

#===============================================================================
# AccuracyCalcTargetAbility handlers
#===============================================================================

BattleHandlers::AccuracyCalcTargetAbility.add(:LIGHTNINGROD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if type == :ELECTRIC
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:NOGUARD,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SANDVEIL,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_multiplier] *= 1.25 if target.battle.pbWeather == :Sandstorm
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:SNOWCLOAK,
  proc { |ability,mods,user,target,move,type|
    mods[:evasion_multiplier] *= 1.25 if target.battle.pbWeather == :Hail
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:STORMDRAIN,
  proc { |ability,mods,user,target,move,type|
    mods[:base_accuracy] = 0 if type == :WATER
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:TANGLEDFEET,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] /= 2 if target.effects[PBEffects::Confusion] > 0
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:UNAWARE,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_stage] = 0 if move.damagingMove?
  }
)

BattleHandlers::AccuracyCalcTargetAbility.add(:WONDERSKIN,
  proc { |ability,mods,user,target,move,type|
    if move.statusMove? && user.opposes?(target)
      mods[:base_accuracy] = 50 if mods[:base_accuracy] > 50
    end
  }
)

#===============================================================================
# DamageCalcUserAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAbility.add(:AERILATE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.powerBoost
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:PIXILATE,:REFRIGERATE,:GALVANIZE)

BattleHandlers::DamageCalcUserAbility.add(:ANALYTIC,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if (target.battle.choices[target.index][0]!=:UseMove &&
       target.battle.choices[target.index][0]!=:Shift) ||
       target.movedThisRound?
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:BLAZE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DEFEATIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] /= 2 if user.hp <= user.totalhp / 2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLAREBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.burned? && move.specialMove?
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLASHFIRE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.effects[PBEffects::FlashFire] && type == :FIRE
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.physicalMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather) && !target.hasUtilityUmbrella?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GUTS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.pbHasAnyStatus? && move.physicalMove?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HUGEPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:HUGEPOWER,:PUREPOWER)

BattleHandlers::DamageCalcUserAbility.add(:HUSTLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:IRONFIST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.punchingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MEGALAUNCHER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.pulseMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MINUS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    user.eachAlly do |b|
      next if !b.hasActiveAbility?([:MINUS, :PLUS])
      mults[:attack_multiplier] *= 1.5
      break
    end
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:MINUS,:PLUS)

BattleHandlers::DamageCalcUserAbility.add(:NEUROFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 1.25
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:OVERGROW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :GRASS
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RECKLESS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.2 if move.recoilMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RIVALRY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.gender!=2 && target.gender!=2
      if user.gender==target.gender
        mults[:base_damage_multiplier] *= 1.25
      else
        mults[:base_damage_multiplier] *= 0.75
      end
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SANDFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.pbWeather == :Sandstorm &&
       [:ROCK, :GROUND, :STEEL].include?(type)
      mults[:base_damage_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SHEERFORCE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.3 if move.addlEffect > 0
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SLOWSTART,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] /= 2 if user.effects[PBEffects::SlowStart] > 0 && move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SOLARPOWER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather) && !target.hasUtilityUmbrella?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SNIPER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.damageState.critical
      mults[:final_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STAKEOUT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if target.battle.choices[target.index][0] == :SwitchOut
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELWORKER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STRONGJAW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if move.bitingMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:SWARM,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :BUG
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TECHNICIAN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.index != target.index && move && move.id != :STRUGGLE &&
       baseDmg * mults[:base_damage_multiplier] <= 60
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TINTEDLENS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 2 if Effectiveness.resistant?(target.damageState.typeMod)
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TORRENT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3 && type == :WATER
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOUGHCLAWS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 4 / 3.0 if move.contactMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TOXICBOOST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.poisoned? && move.physicalMove?
      mults[:base_damage_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 2 if type == :WATER
  }
)

BattleHandlers::DamageCalcUserAbility.add(:GORILLATACTICS,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if move.physicalMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:PUNKROCK,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.3 if move.soundMove?
  }
)

BattleHandlers::DamageCalcUserAbility.add(:STEELYSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

BattleHandlers::DamageCalcUserAbility.add(:DRAGONSMAW,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :DRAGON
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TRANSISTOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if type == :ELECTRIC
  }
)

#===============================================================================
# DamageCalcUserAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcUserAllyAbility.add(:BATTERY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next if !move.specialMove?
    mults[:final_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.physicalMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather) && !target.hasUtilityUmbrella?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:POWERSPOT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 1.3
  }
)

BattleHandlers::DamageCalcUserAllyAbility.add(:STEELYSPIRIT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.5 if type == :STEEL
  }
)

#===============================================================================
# DamageCalcTargetAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbility.add(:DRYSKIN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] *= 1.25 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FILTER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:FILTER,:SOLIDROCK)

BattleHandlers::DamageCalcTargetAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather) && !target.hasUtilityUmbrella?
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FLUFFY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 2 if move.calcType == :FIRE
    mults[:final_damage_multiplier] /= 2 if move.pbContactMove?(user)
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:FURCOAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:defense_multiplier] *= 2 if move.physicalMove? || move.function == "122"   # Psyshock
  }
)

  BattleHandlers::DamageCalcTargetAbility.add(:ICESCALES,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if move.specialMove?
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:GRASSPELT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.battle.field.terrain == :Grassy
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:HEATPROOF,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MARVELSCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.pbHasAnyStatus? && move.physicalMove?
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MULTISCALE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if target.hp == target.totalhp
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:THICKFAT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :FIRE || type == :ICE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:WATERBUBBLE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if type == :FIRE
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:PUNKROCK,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] /= 2 if move.soundMove?
  }
)

#===============================================================================
# DamageCalcTargetAbilityNonIgnorable handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:PRISMARMOR,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if Effectiveness.super_effective?(target.damageState.typeMod)
      mults[:final_damage_multiplier] *= 0.75
    end
  }
)

BattleHandlers::DamageCalcTargetAbilityNonIgnorable.add(:SHADOWSHIELD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if target.hp==target.totalhp
      mults[:final_damage_multiplier] /= 2
    end
  }
)

#===============================================================================
# DamageCalcTargetAllyAbility handlers
#===============================================================================

BattleHandlers::DamageCalcTargetAllyAbility.add(:FLOWERGIFT,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Sun, :HarshSun].include?(user.battle.pbWeather) && !target.hasUtilityUmbrella?
      mults[:defense_multiplier] *= 1.5
    end
  }
)

BattleHandlers::DamageCalcTargetAllyAbility.add(:FRIENDGUARD,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= 0.75
  }
)

#===============================================================================
# CriticalCalcUserAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcUserAbility.add(:MERCILESS,
  proc { |ability,user,target,c|
    next 99 if target.poisoned?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:SUPERLUCK,
  proc { |ability,user,target,c|
    next c+1
  }
)

#===============================================================================
# CriticalCalcTargetAbility handlers
#===============================================================================

BattleHandlers::CriticalCalcTargetAbility.add(:BATTLEARMOR,
  proc { |ability,user,target,c|
    next -1
  }
)

BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:SHELLARMOR,
                                               :GALARSFLAME,:HOENNSIRON) # Arc Suit

#===============================================================================
# TargetAbilityOnHit handlers
#===============================================================================

BattleHandlers::TargetAbilityOnHit.add(:AFTERMATH,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if !battle.moldBreaker
      dampBattler = battle.pbCheckGlobalAbility(:DAMP)
      if dampBattler
        battle.pbShowAbilitySplash(dampBattler)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1} cannot use {2}!",target.pbThis,target.abilityName))
        else
          battle.pbDisplay(_INTL("{1} cannot use {2} because of {3}'s {4}!",
             target.pbThis,target.abilityName,dampBattler.pbThis(true),dampBattler.abilityName))
        end
        battle.pbHideAbilitySplash(dampBattler)
        battle.pbHideAbilitySplash(target)
        next
      end
    end
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/4,false)
      battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:ANGERPOINT,
  proc { |ability,user,target,move,battle|
    next if !target.damageState.critical
    next if !target.pbCanRaiseStatStage?(:ATTACK,target)
    battle.pbShowAbilitySplash(target)
    target.stages[:ATTACK] = 6
    battle.pbCommonAnimation("StatUp",target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} maxed its {2}!",target.pbThis,GameData::Stat.get(:ATTACK).name))
    else
      battle.pbDisplay(_INTL("{1}'s {2} maxed its {3}!",
         target.pbThis,target.abilityName,GameData::Stat.get(:ATTACK).name))
    end
    target.statsRaised = true
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CURSEDBODY,
  proc { |ability,user,target,move,battle|
    next if user.fainted?
    next if user.effects[PBEffects::Disable]>0
    regularMove = nil
    user.eachMove do |m|
      next if m.id!=user.lastRegularMoveUsed
      regularMove = m
      break
    end
    next if !regularMove || (regularMove.pp==0 && regularMove.total_pp>0)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if !move.pbMoveFailedAromaVeil?(target,user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::Disable]     = 3
      user.effects[PBEffects::DisableMove] = regularMove.id
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} was disabled!",user.pbThis,regularMove.name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} was disabled by {3}'s {4}!",
           user.pbThis,regularMove.name,target.pbThis(true),target.abilityName))
      end
      battle.pbHideAbilitySplash(target)
      user.pbItemStatusCureCheck
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:CUTECHARM,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanAttract?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} made {3} fall in love!",target.pbThis,
           target.abilityName,user.pbThis(true))
      end
      user.pbAttract(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:EFFECTSPORE,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 30% chance of triggering, not a 30% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if !move.pbContactMove?(user)
    next if battle.pbRandom(100)>=30
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbPoison(target,msg)
        end
      when 2
        if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,target.abilityName,user.pbThis(true))
          end
          user.pbParalyze(target,msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:FLAMEBODY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.burned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanBurn?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbBurn(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GOOEY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    user.pbLowerStatStageByAbility(:SPEED,1,target,true,true)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:GOOEY,:TANGLINGHAIR)

BattleHandlers::TargetAbilityOnHit.add(:ILLUSION,
  proc { |ability,user,target,move,battle|
    # NOTE: This intentionally doesn't show the ability splash.
    next if !target.effects[PBEffects::Illusion]
    battle.pbCommonAnimation("Illusion", target)
    target.effects[PBEffects::Illusion] = nil
    battle.scene.pbChangePokemon(target,target.pokemon)
    battle.pbCommonAnimation("Fade in", target)
    battle.pbDisplay(_INTL("{1}'s illusion wore off!",target.pbThis))
    battle.pbSetSeen(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:INNARDSOUT,
  proc { |ability,user,target,move,battle|
    next if !target.fainted? || user.dummy
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(target.damageState.hpLost,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:IRONBARBS,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    battle.pbShowAbilitySplash(target)
    if user.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      battle.scene.pbDamageAnimation(user)
      user.pbReduceHP(user.totalhp/8,false)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
           target.pbThis(true),target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.copy(:IRONBARBS,:ROUGHSKIN)

BattleHandlers::TargetAbilityOnHit.add(:JUSTIFIED,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :DARK
    target.pbRaiseStatStageByAbility(:ATTACK,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:MUMMY,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.unstoppableAbility? || user.ability == ability
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = ability
      battle.pbReplaceAbilitySplash(user) if user.opposes?(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end
      battle.pbHideAbilitySplash(user) if user.opposes?(target)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    user.pbOnAbilityChanged(oldAbil) if oldAbil != nil
  }
)

BattleHandlers::TargetAbilityOnHit.add(:POISONPOINT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.poisoned? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbPoison(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:RATTLED,
  proc { |ability,user,target,move,battle|
    next if ![:BUG, :DARK, :GHOST].include?(move.calcType)
    target.pbRaiseStatStageByAbility(:SPEED,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STAMINA,
  proc { |ability,user,target,move,battle|
    target.pbRaiseStatStageByAbility(:DEFENSE,1,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SANDSPIT,
  proc { |ability,target,battler,move,battle|
    pbBattleWeatherAbility(:Sandstorm,battler,battle)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STATIC,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.paralyzed? || battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(target)
    if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
           target.pbThis,target.abilityName,user.pbThis(true))
      end
      user.pbParalyze(target,msg)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WATERCOMPACTION,
  proc { |ability,user,target,move,battle|
    next if move.calcType != :WATER
    target.pbRaiseStatStageByAbility(:DEFENSE,2,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WEAKARMOR,
  proc { |ability,user,target,move,battle|
    next if !move.physicalMove?
    next if !target.pbCanLowerStatStage?(:DEFENSE, target) &&
            !target.pbCanRaiseStatStage?(:SPEED, target)
    battle.pbShowAbilitySplash(target)
    target.pbLowerStatStageByAbility(:DEFENSE, 1, target, false)
    target.pbRaiseStatStageByAbility(:SPEED,
       (Settings::MECHANICS_GENERATION >= 7) ? 2 : 1, target, false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:STEAMENGINE,
  proc { |ability,user,target,move,battle|
    next if ![:FIRE,:WATER].include?(move.calcType)
    target.pbRaiseStatStageByAbility(:SPEED,6,target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:WANDERINGSPIRIT,
  proc { |ability,user,target,move,battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    abilityBlacklist = [
       :DISGUISE,
       :FLOWERGIFT,
       :GULPMISSILE,
       :ICEFACE,
       :IMPOSTER,
       :RECEIVER,
       :RKSSYSTEM,
       :SCHOOLING,
       :STANCECHANGE,
       :WONDERGUARD,
       :ZENMODE,
       :NEUTRALIZINGGAS
       # Abilities that are plain old blocked.
    ]
    next if abilityBlacklist.any? {|abil| user.ability == abil}
    oldAbil = nil
    battle.pbShowAbilitySplash(target) if user.opposes?(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldAbil = user.ability
      battle.pbShowAbilitySplash(user,true,false) if user.opposes?(target)
      user.ability = :WANDERINGSPIRIT
      target.ability = oldAbil
      if user.opposes?(target)
        battle.pbReplaceAbilitySplash(user)
        battle.pbReplaceAbilitySplash(target)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s Ability became {2}!",user.pbThis,user.abilityName))
      else
        battle.pbDisplay(_INTL("{1}'s Ability became {2} because of {3}!",
           user.pbThis,user.abilityName,target.pbThis(true)))
      end

      battle.pbHideAbilitySplash(user)
    end
    battle.pbHideAbilitySplash(target) if user.opposes?(target)
    if oldAbil
      user.pbOnAbilityChanged(oldAbil)
      target.pbOnAbilityChanged(:WANDERINGSPIRIT)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PERISHBODY,
  proc { |ability, user, target, move, battle|
    next if !move.pbContactMove?(user)
    next if user.fainted?
    next if user.effects[PBEffects::PerishSong] > 0 || target.effects[PBEffects::PerishSong] > 0
    battle.pbShowAbilitySplash(target)
    if user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      user.effects[PBEffects::PerishSong] = 4
      user.effects[PBEffects::PerishSongUser] = target.index
      target.effects[PBEffects::PerishSong] = 4
      target.effects[PBEffects::PerishSongUser] = target.index
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns!"))
      else
        battle.pbDisplay(_INTL("Both Pokémon will faint in three turns because of {1}'s {2}!",
           target.pbThis(true), target.abilityName))
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:COTTONDOWN,
  proc { |ability,user,target,move,battle|
    splashAnim = false
    battle.pbShowAbilitySplash(target)
    battle.pbPriority(true).each {|b|
      next if b.index == target.index || !b.pbCanLowerStatStage?(:SPEED,target)
      b.pbLowerStatStageByAbility(:SPEED,1,target,!splashAnim)
      splashAnim = true
    }
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:GULPMISSILE,
  proc { |ability,user,target,move,battle|
    next if !target.isSpecies?(:CRAMORANT)
    next if target.form == 0
    battle.pbShowAbilitySplash(target)
    oldForm = target.form
    target.pbChangeForm(0,"")
    battle.pbHideAbilitySplash(target)
    if oldForm == 1
      battle.pbCommonAnimation("CramorantGulp",user,target)
    elsif oldForm == 2
      battle.pbCommonAnimation("CramorantGorge",user,target)
    end
    user.pbReduceHP(user.totalhp/4) if user.takesIndirectDamage?(true)
    if oldForm == 1
      user.pbLowerStatStageByAbility(:DEFENSE,1,target,false)
    elsif oldForm == 2
      user.pbParalyze(target,"")
    end
  }
)

#===============================================================================
# UserAbilityOnHit handlers
#===============================================================================

BattleHandlers::UserAbilityOnHit.add(:POISONTOUCH,
  proc { |ability,user,target,move,battle|
    next if !move.contactMove?
    next if battle.pbRandom(100)>=30
    battle.pbShowAbilitySplash(user)
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} poisoned {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbPoison(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# UserAbilityEndOfMove handlers
#===============================================================================

BattleHandlers::UserAbilityEndOfMove.add(:BEASTBOOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted == 0
    userStats = user.plainStats
    highestStatValue = 0
    userStats.each_value { |value| highestStatValue = value if highestStatValue < value }
    GameData::Stat.each_main_battle do |s|
      next if userStats[s.id] < highestStatValue
      if user.pbCanRaiseStatStage?(s.id, user)
        user.pbRaiseStatStageByAbility(s.id, numFainted, user)
      end
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MAGICIAN,
  proc { |ability,user,targets,move,battle|
    next if battle.futureSight
    next if !move.pbDamagingMove?
    next if user.item
    next if battle.wildBattle? && user.opposes?
    targets.each do |b|
      next if b.damageState.unaffected || b.damageState.substitute
      next if !b.item
      next if b.unlosableItem?(b.item) || user.unlosableItem?(b.item)
      battle.pbShowAbilitySplash(user)
      if (b.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker) ||        
          (!@battle.wildBattle? && !b.pbOwnedByPlayer? &&
          inSyncOrTitan) # Sygna Challenge
        battle.pbShowAbilitySplash(b) if user.opposes?(b)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",b.pbThis))
        end
        battle.pbHideAbilitySplash(b) if user.opposes?(b)
        next
      end
      user.item = b.item
      b.item = nil
      b.effects[PBEffects::Unburden] = true
      if battle.wildBattle? && !user.initialItem && b.initialItem==user.item
        user.setInitialItem(user.item)
        b.setInitialItem(nil)
      end
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",user.pbThis,
           b.pbThis(true),user.itemName))
      else
        battle.pbDisplay(_INTL("{1} stole {2}'s {3} with {4}!",user.pbThis,
           b.pbThis(true),user.itemName,user.abilityName))
      end
      battle.pbHideAbilitySplash(user)
      user.pbHeldItemTriggerCheck
      break
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MOXIE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user)
    user.pbRaiseStatStageByAbility(:ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.copy(:MOXIE,:CHILLINGNEIGH)

BattleHandlers::UserAbilityEndOfMove.add(:GRIMNEIGH,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user)
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,numFainted,user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEICE,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:ATTACK,user) || user.fainted?
    battle.pbShowAbilitySplash(user,false,true,GameData::Ability.get(:CHILLINGNEIGH).name)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      user.pbRaiseStatStage(:ATTACK,numFainted,user)
    else
      user.pbRaiseStatStageByCause(:ATTACK,numFainted,user,GameData::Ability.get(:CHILLINGNEIGH).name)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ASONEGHOST,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0 || !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user) || user.fainted?
    battle.pbShowAbilitySplash(user,false,true,GameData::Ability.get(:GRIMNEIGH).name)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      user.pbRaiseStatStage(:SPECIAL_ATTACK,numFainted,user)
    else
      user.pbRaiseStatStageByCause(:SPECIAL_ATTACK,numFainted,user,GameData::Ability.get(:GRIMNEIGH).name)
    end
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# TargetAbilityAfterMoveUse handlers
#===============================================================================

BattleHandlers::TargetAbilityAfterMoveUse.add(:BERSERK,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
    next if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:COLORCHANGE,
  proc { |ability,target,user,move,switched,battle|
    next if target.damageState.calcDamage==0 || target.damageState.substitute
    next if !move.calcType || GameData::Type.get(move.calcType).pseudo_type
    next if target.pbHasType?(move.calcType) && !target.pbHasOtherType?(move.calcType)
    typeName = GameData::Type.get(move.calcType).name
    battle.pbShowAbilitySplash(target)
    target.pbChangeTypes(move.calcType)
    battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
       target.abilityName,typeName))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityAfterMoveUse.add(:PICKPOCKET,
  proc { |ability,target,user,move,switched,battle|
    # NOTE: According to Bulbapedia, this can still trigger to steal the user's
    #       item even if it was switched out by a Red Card. This doesn't make
    #       sense, so this code doesn't do it.
    next if battle.wildBattle? && target.opposes?
    next if !move.contactMove?
    next if switched.include?(user.index)
    next if user.effects[PBEffects::Substitute]>0 || target.damageState.substitute
    next if target.item || !user.item
    next if user.unlosableItem?(user.item) || target.unlosableItem?(user.item)
    battle.pbShowAbilitySplash(target)
    if (user.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker) ||        
        (!@battle.wildBattle? && !user.pbOwnedByPlayer? &&
        inSyncOrTitan) # Sygna Challenge
      battle.pbShowAbilitySplash(user) if target.opposes?(user)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s item cannot be stolen!",user.pbThis))
      end
      battle.pbHideAbilitySplash(user) if target.opposes?(user)
      battle.pbHideAbilitySplash(target)
      next
    end
    target.item = user.item
    user.item = nil
    user.effects[PBEffects::Unburden] = true
    if battle.wildBattle? && !target.initialItem && user.initialItem==target.item
      target.setInitialItem(target.item)
      user.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
       user.pbThis(true),target.itemName))
    battle.pbHideAbilitySplash(target)
    target.pbHeldItemTriggerCheck
  }
)

#===============================================================================
# EORWeatherAbility handlers
#===============================================================================

BattleHandlers::EORWeatherAbility.add(:DRYSKIN,
  proc { |ability,weather,battler,battle|
    case weather
    when :Sun, :HarshSun
      next if battler.hasUtilityUmbrella?
      battle.pbShowAbilitySplash(battler)
      battle.scene.pbDamageAnimation(battler)
      battler.pbReduceHP(battler.totalhp/8,false)
      battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
      battler.pbItemHPHealCheck
    when :Rain, :HeavyRain
      next if battler.hasUtilityUmbrella?
      next if !battler.canHeal?
      battle.pbShowAbilitySplash(battler)
      battler.pbRecoverHP(battler.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORWeatherAbility.add(:ICEBODY,
  proc { |ability,weather,battler,battle|
    next unless weather == :Hail
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/8)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:RAINDISH,
  proc { |ability,weather,battler,battle|
    next unless [:Rain, :HeavyRain].include?(weather)
    next if battler.hasUtilityUmbrella?
    next if !battler.canHeal?
    battle.pbShowAbilitySplash(battler)
    battler.pbRecoverHP(battler.totalhp/16)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s {2} restored its HP.",battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORWeatherAbility.add(:SOLARPOWER,
  proc { |ability,weather,battler,battle|
    next unless [:Sun, :HarshSun].include?(weather)
    next if battler.hasUtilityUmbrella?
    battle.pbShowAbilitySplash(battler)
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp/8,false)
    battle.pbDisplay(_INTL("{1} was hurt by the sunlight!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    battler.pbItemHPHealCheck
  }
)

#===============================================================================
# EORHealingAbility handlers
#===============================================================================

BattleHandlers::EORHealingAbility.add(:HEALER,
  proc { |ability,battler,battle|
    next unless battle.pbRandom(100)<30
    battler.eachAlly do |b|
      next if b.status == :NONE
      battle.pbShowAbilitySplash(battler)
      oldStatus = b.status
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        case oldStatus
        when :SLEEP
          battle.pbDisplay(_INTL("{1}'s {2} woke its partner up!",battler.pbThis,battler.abilityName))
        when :POISON
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's poison!",battler.pbThis,battler.abilityName))
        when :BURN
          battle.pbDisplay(_INTL("{1}'s {2} healed its partner's burn!",battler.pbThis,battler.abilityName))
        when :PARALYSIS
          battle.pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis!",battler.pbThis,battler.abilityName))
        when :FROZEN
          battle.pbDisplay(_INTL("{1}'s {2} defrosted its partner!",battler.pbThis,battler.abilityName))
        end
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::EORHealingAbility.add(:HYDRATION,
  proc { |ability,battler,battle|
    next if battler.status == :NONE
    next if ![:Rain, :HeavyRain].include?(battle.pbWeather)
    next if battler.hasUtilityUmbrella?
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::EORHealingAbility.add(:SHEDSKIN,
  proc { |ability,battler,battle|
    next if battler.status == :NONE
    next unless battle.pbRandom(100)<30
    battle.pbShowAbilitySplash(battler)
    oldStatus = battler.status
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      case oldStatus
      when :SLEEP
        battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,battler.abilityName))
      when :POISON
        battle.pbDisplay(_INTL("{1}'s {2} cured its poison!",battler.pbThis,battler.abilityName))
      when :BURN
        battle.pbDisplay(_INTL("{1}'s {2} healed its burn!",battler.pbThis,battler.abilityName))
      when :PARALYSIS
        battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis!",battler.pbThis,battler.abilityName))
      when :FROZEN
        battle.pbDisplay(_INTL("{1}'s {2} defrosted it!",battler.pbThis,battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EOREffectAbility handlers
#===============================================================================

BattleHandlers::EOREffectAbility.add(:BADDREAMS,
  proc { |ability,battler,battle|
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler) || !b.asleep?
      battle.pbShowAbilitySplash(battler)
      next if !b.takesIndirectDamage?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      oldHP = b.hp
      b.pbReduceHP(b.totalhp/8)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is tormented!",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1} is tormented by {2}'s {3}!",b.pbThis,
           battler.pbThis(true),battler.abilityName))
      end
      battle.pbHideAbilitySplash(battler)
      b.pbItemHPHealCheck
      b.pbAbilitiesOnDamageTaken(oldHP)
      b.pbFaint if b.fainted?
    end
  }
)

BattleHandlers::EOREffectAbility.add(:MOODY,
  proc { |ability,battler,battle|
    randomUp = []
    randomDown = []
    GameData::Stat.each_main_battle do |s|
      randomUp.push(s.id) if battler.pbCanRaiseStatStage?(s.id, battler)
      randomDown.push(s.id) if battler.pbCanLowerStatStage?(s.id, battler)
    end
    next if randomUp.length==0 && randomDown.length==0
    battle.pbShowAbilitySplash(battler)
    if randomUp.length>0
      r = battle.pbRandom(randomUp.length)
      battler.pbRaiseStatStageByAbility(randomUp[r],2,battler,false)
      randomDown.delete(randomUp[r])
    end
    if randomDown.length>0
      r = battle.pbRandom(randomDown.length)
      battler.pbLowerStatStageByAbility(randomDown[r],1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
    battler.pbItemStatRestoreCheck if randomDown.length>0
  }
)

BattleHandlers::EOREffectAbility.add(:SPEEDBOOST,
  proc { |ability,battler,battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount > 0 && battle.choices[battler.index][0] != :Run &&
       battler.pbCanRaiseStatStage?(:SPEED, battler)
      battler.pbRaiseStatStageByAbility(:SPEED,1,battler)
    end
  }
)

BattleHandlers::EOREffectAbility.add(:HUNGERSWITCH,
  proc { |ability,battler,battle|
    next if !battler.isSpecies?(:MORPEKO)
    battle.pbShowAbilitySplash(battler)
    newForm = (battler.form == 0) ? 1 : 0
    battler.pbChangeForm(newForm,_INTL("{1} transformed!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# EORGainItemAbility handlers
#===============================================================================

BattleHandlers::EORGainItemAbility.add(:HARVEST,
  proc { |ability,battler,battle|
    next if battler.item
    next if !battler.recycleItem || !GameData::Item.get(battler.recycleItem).is_berry?
    if ![:Sun, :HarshSun].include?(battle.pbWeather) ||
       ([:Sun, :HarshSun].include?(battle.pbWeather) && battler.hasUtilityUmbrella?)
      next unless battle.pbRandom(100)<50
    end
    battle.pbShowAbilitySplash(battler)
    battler.item = battler.recycleItem
    battler.setRecycleItem(nil)
    battler.setInitialItem(battler.item) if !battler.initialItem
    battle.pbDisplay(_INTL("{1} harvested one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

BattleHandlers::EORGainItemAbility.add(:PICKUP,
  proc { |ability,battler,battle|
    next if battler.item
    foundItem = nil; fromBattler = nil; use = 0
    battle.eachBattler do |b|
      next if b.index==battler.index
      next if b.effects[PBEffects::PickupUse]<=use
      foundItem   = b.effects[PBEffects::PickupItem]
      fromBattler = b
      use         = b.effects[PBEffects::PickupUse]
    end
    next if !foundItem
    battle.pbShowAbilitySplash(battler)
    battler.item = foundItem
    fromBattler.effects[PBEffects::PickupItem] = nil
    fromBattler.effects[PBEffects::PickupUse]  = 0
    fromBattler.setRecycleItem(nil) if fromBattler.recycleItem==foundItem
    if battle.wildBattle? && !battler.initialItem && fromBattler.initialItem==foundItem
      battler.setInitialItem(foundItem)
      fromBattler.setInitialItem(nil)
    end
    battle.pbDisplay(_INTL("{1} found one {2}!",battler.pbThis,battler.itemName))
    battle.pbHideAbilitySplash(battler)
    battler.pbHeldItemTriggerCheck
  }
)

BattleHandlers::EORGainItemAbility.add(:BALLFETCH,
  proc { |ability,battler,battle|
    next if battler.item
    next if !battler.effects[PBEffects::BallFetch]
    next if battle.fetchedBall
    battle.fetchedBall = true
    battler.item = battler.effects[PBEffects::BallFetch]
    battler.effects[PBEffects::BallFetch] = nil
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s Ball Fetch found #{GameData::Item.get(battler.item).name}")
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} found a {2}!",battler.pbThis,GameData::Item.get(battler.item).name))
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# CertainSwitchingUserAbility handlers
#===============================================================================

# There aren't any!

#===============================================================================
# TrappingTargetAbility handlers
#===============================================================================

BattleHandlers::TrappingTargetAbility.add(:ARENATRAP,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.airborne?
  }
)

BattleHandlers::TrappingTargetAbility.add(:MAGNETPULL,
  proc { |ability,switcher,bearer,battle|
    next true if switcher.pbHasType?(:STEEL)
  }
)

BattleHandlers::TrappingTargetAbility.add(:SHADOWTAG,
  proc { |ability,switcher,bearer,battle|
    next true if !switcher.hasActiveAbility?(:SHADOWTAG)
  }
)

#===============================================================================
# AbilityOnSwitchIn handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchIn.add(:AIRLOCK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} has {2}!",battler.pbThis,battler.abilityName))
    end
    battle.pbDisplay(_INTL("The effects of the weather disappeared."))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:AIRLOCK,:CLOUDNINE)

BattleHandlers::AbilityOnSwitchIn.add(:ANTICIPATION,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    battlerTypes = battler.pbTypes(true)
    type1 = battlerTypes[0]
    type2 = battlerTypes[1] || type1
    type3 = battlerTypes[2] || type2
    found = false
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        next if m.statusMove?
        if type1
          moveType = m.type
          if Settings::MECHANICS_GENERATION >= 6 && m.function == "090"   # Hidden Power
            moveType = pbHiddenPower(b.pokemon)[0]
          end
          eff = Effectiveness.calculate(moveType,type1,type2,type3)
          next if Effectiveness.ineffective?(eff)
          next if !Effectiveness.super_effective?(eff) && m.function != "070"   # OHKO
        else
          next if m.function != "070"   # OHKO
        end
        found = true
        break
      end
      break if found
    end
    if found
      battle.pbShowAbilitySplash(battler)
      battle.pbDisplay(_INTL("{1} shuddered with anticipation!",battler.pbThis))
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AURABREAK,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} reversed all other Pokémon's auras!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COMATOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is drowsing!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DARKAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a dark aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DELTASTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:StrongWinds, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DESOLATELAND,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HarshSun, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNLOAD,
  proc { |ability,battler,battle|
    oDef = oSpDef = 0
    battle.eachOtherSideBattler(battler.index) do |b|
      oDef   += b.defense
      oSpDef += b.spdef
    end
    stat = (oDef<oSpDef) ? :ATTACK : :SPECIAL_ATTACK
    battler.pbRaiseStatStageByAbility(stat,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRIZZLE,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Rain, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DROUGHT,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sun, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ELECTRICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Electric)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FAIRYAURA,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fairy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FOREWARN,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    highestPower = 0
    forewarnMoves = []
    battle.eachOtherSideBattler(battler.index) do |b|
      b.eachMove do |m|
        power = m.baseDamage
        power = 160 if ["070"].include?(m.function)    # OHKO
        power = 150 if ["08B"].include?(m.function)    # Eruption
        # Counter, Mirror Coat, Metal Burst
        power = 120 if ["071","072","073"].include?(m.function)
        # Sonic Boom, Dragon Rage, Night Shade, Endeavor, Psywave,
        # Return, Frustration, Crush Grip, Gyro Ball, Hidden Power,
        # Natural Gift, Trump Card, Flail, Grass Knot
        power = 80 if ["06A","06B","06D","06E","06F",
                       "089","08A","08C","08D","090",
                       "096","097","098","09A"].include?(m.function)
        next if power<highestPower
        forewarnMoves = [] if power>highestPower
        forewarnMoves.push(m.name)
        highestPower = power
      end
    end
    if forewarnMoves.length>0
      battle.pbShowAbilitySplash(battler)
      forewarnMoveName = forewarnMoves[battle.pbRandom(forewarnMoves.length)]
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} was alerted to {2}!",
          battler.pbThis, forewarnMoveName))
      else
        battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",
          battler.pbThis, forewarnMoveName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FRISK,
  proc { |ability,battler,battle|
    next if !battler.pbOwnedByPlayer?
    foes = []
    battle.eachOtherSideBattler(battler.index) do |b|
      foes.push(b) if b.item
    end
    if foes.length>0
      battle.pbShowAbilitySplash(battler)
      if Settings::MECHANICS_GENERATION >= 6
        foes.each do |b|
          battle.pbDisplay(_INTL("{1} frisked {2} and found its {3}!",
             battler.pbThis,b.pbThis(true),b.itemName))
        end
      else
        foe = foes[battle.pbRandom(foes.length)]
        battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",
           battler.pbThis,foe.itemName))
      end
      battle.pbHideAbilitySplash(battler)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRASSYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Grassy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Grassy)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSTER,
  proc { |ability,battler,battle|
    next if battler.effects[PBEffects::Transform]
    choice = battler.pbDirectOpposing
    next if choice.fainted?
    next if choice.effects[PBEffects::Transform] ||
            choice.effects[PBEffects::Illusion] ||
            choice.effects[PBEffects::Substitute]>0 ||
            choice.effects[PBEffects::SkyDrop]>=0 ||
            choice.semiInvulnerable?
    battle.pbShowAbilitySplash(battler,true)
    battle.pbHideAbilitySplash(battler)
    battle.pbAnimation(:TRANSFORM,battler,choice)
    battle.scene.pbChangePokemon(battler,choice.pokemon)
    battler.pbTransform(choice)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:INTIMIDATE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerAttackStatStageIntimidate(battler)
      check_item = true
      if b.hasActiveAbility?(:CONTRARY)
        check_item = false if b.statStageAtMax?(:ATTACK)
      else
        check_item = false if b.statStageAtMin?(:ATTACK)
      end
      b.pbItemOnIntimidatedCheck if check_item
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MISTYSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Misty
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Misty)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:MOLDBREAKER,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} breaks the mold!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRESSURE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is exerting its pressure!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIMORDIALSEA,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:HeavyRain, battler, battle, true)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PSYCHICSURGE,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Psychic)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDSTREAM,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sandstorm, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SLOWSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battler.effects[PBEffects::SlowStart] = 5
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} can't get it going!",battler.pbThis))
    else
      battle.pbDisplay(_INTL("{1} can't get it going because of its {2}!",
         battler.pbThis,battler.abilityName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SNOWWARNING,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Hail, battler, battle)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TERAVOLT,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a bursting aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TURBOBLAZE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a blazing aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UNNERVE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ASONEICE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} has 2 Abilities!",battler.name))
    battle.pbShowAbilitySplash(battler,false,true,GameData::Ability.get(:UNNERVE).name)
    battle.pbDisplay(_INTL("{1} is too nervous to eat Berries!",battler.pbOpposingTeam))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:ASONEICE,:ASONEGHOST)

BattleHandlers::AbilityOnSwitchIn.add(:INTREPIDSWORD,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:ATTACK,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DAUNTLESSSHIELD,
  proc { |ability,battler,battle|
    battler.pbRaiseStatStageByAbility(:DEFENSE,1,battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SCREENCLEANER,
  proc { |ability,battler,battle|
    splashAnim = false
    side = [battler.pbOwnSide,battler.pbOpposingSide]
    team = [battler.pbTeam,battler.pbOpposingTeam]
    effects = [:AuroraVeil, :LightScreen, :Reflect].map!{|e| getConst(PBEffects,e)}
    effectNames = ["Aurora Veil", "Light Screen", "Reflect"]
    for i in 0...2
      effects.each_with_index do |e,j|
        next if side[i].effects[e] < 1
        battle.pbShowAbilitySplash(battler) if !splashAnim
        side[i].effects[e] = 0
        battle.pbDisplay(_INTL("{1}'s {2} wore off!",team[i],effectNames[j]))
        splashAnim = true
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASTELVEIL,
  proc { |ability,battler,battle|
    splashAnim = false
    battler.eachAlly do |b|
      next if b.status != :POISON
      battle.pbShowAbilitySplash(battler) if !splashAnim
      splashAnim = true
      b.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cured its {3}'s poison!",battler.pbThis,battler.abilityName,b.pbThis(true)))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CURIOUSMEDICINE,
  proc { |ability, battler, battle|
    splashAnim = false
    battler.eachAlly do |b|
      next if !b.hasAlteredStatStages?
      battle.pbShowAbilitySplash(battler) if !splashAnim
      splashAnim = true
      b.pbResetStatStages
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stat changes were removed!", b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s stat changes were removed by {2}'s {3}!",
           b.pbThis, battler.pbThis(true), battler.abilityName))
      end
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:NEUTRALIZINGGAS,
  proc { |ability,battler,battle|
    next if battle.field.effects[PBEffects::NeutralizingGas]
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s gas nullified all abilities!",battler.pbThis))
    battle.field.effects[PBEffects::NeutralizingGas] = true
    battle.pbHideAbilitySplash(battler)
  }
)


#===============================================================================
# AbilityOnSwitchOut handlers
#===============================================================================

BattleHandlers::AbilityOnSwitchOut.add(:NATURALCURE,
  proc { |ability,battler,endOfBattle|
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:REGENERATOR,
  proc { |ability,battler,endOfBattle|
    next if endOfBattle
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.pbRecoverHP(battler.totalhp/3,false,false)
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:IMMUNITY,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :POISON
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:INSOMNIA,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :SLEEP
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.copy(:INSOMNIA, :VITALSPIRIT)

BattleHandlers::AbilityOnSwitchOut.add(:LIMBER,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :PARALYSIS
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:MAGMAARMOR,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :FROZEN
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.add(:WATERVEIL,
  proc { |ability, battler, endOfBattle|
    next if battler.status != :BURN
    PBDebug.log("[Ability triggered] #{battler.pbThis}'s #{battler.abilityName}")
    battler.status = :NONE
  }
)

BattleHandlers::AbilityOnSwitchOut.copy(:WATERVEIL, :WATERBUBBLE)

#===============================================================================
# AbilityChangeOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityChangeOnBattlerFainting.add(:POWEROFALCHEMY,
  proc { |ability,battler,fainted,battle|
    next if battler.opposes?(fainted)
    next if fainted.ungainableAbility? ||
       [:POWEROFALCHEMY, :RECEIVER, :TRACE, :WONDERGUARD].include?(fainted.ability_id)
    battle.pbShowAbilitySplash(battler,true)
    battler.ability = fainted.ability
    battle.pbReplaceAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1}'s {2} was taken over!",fainted.pbThis,fainted.abilityName))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityChangeOnBattlerFainting.copy(:POWEROFALCHEMY,:RECEIVER)

#===============================================================================
# AbilityOnBattlerFainting handlers
#===============================================================================

BattleHandlers::AbilityOnBattlerFainting.add(:SOULHEART,
  proc { |ability,battler,fainted,battle|
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,battler)
  }
)

#===============================================================================
# RunFromBattleAbility handlers
#===============================================================================

BattleHandlers::RunFromBattleAbility.add(:RUNAWAY,
  proc { |ability,battler|
    next true
  }
)

#===============================================================================
# Sygna Challenge Ability handlers
#===============================================================================
BattleHandlers::AbilityOnSwitchIn.add(:FAIRYKINGDOM,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Fairy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Fairy)
    battle.pbDisplay(_INTL("The Fairy Zone was extended!"))
    battle.field.zoneDuration = 8
  }
)

BattleHandlers::AbilityOnTerrainChange.add(:FAIRYKINGDOM,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.terrain == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Poni Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Poni Ocean Breeze boosts its allies!",battler.pbThis))
    battle.eachBattler do |b|
      next if b.opposes?(battler)
      b.pbRaiseStatStage(:DEFENSE,1,battler)
      b.pbRaiseStatStage(:SPECIAL_DEFENSE,1,battler)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnZoneChange.add(:FAIRYKINGDOM,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.zone == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Poni Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Poni Ocean Breeze boosts its allies!",battler.pbThis))
    battle.eachBattler do |b|
      next if b.opposes?(battler)
      b.pbRaiseStatStage(:DEFENSE,1,battler)
      b.pbRaiseStatStage(:SPECIAL_DEFENSE,1,battler)
    end
    battle.pbHideAbilitySplash(battler)
  }
)
      
BattleHandlers::AbilityOnWeatherChange.add(:FAIRYKINGDOM,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.weather == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Poni Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Poni Ocean Breeze boosts its allies!",battler.pbThis))
    battle.eachBattler do |b|
      next if b.opposes?(battler)
      b.pbRaiseStatStage(:DEFENSE,1,battler)
      b.pbRaiseStatStage(:SPECIAL_DEFENSE,1,battler)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::StatusImmunityAbility.add(:STATUSIMMUNITY,
  proc { |ability,battler,status|
    next true
  }
)

# Despair Challenge (Luc)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD, :PHOENIXREVIVAL,
                                            :PHOENIXRELEASE, :INFINITESPACE)

BattleHandlers::AbilityOnSwitchIn.add(:PHOENIXREVIVAL,
  proc { |ability,battler,battle|
    attackMoves = [Pokemon::Move.new(:HEATWAVE), Pokemon::Move.new(:RECOVER),
                  Pokemon::Move.new(:AEROBLAST), Pokemon::Move.new(:PROTECT)]
    for i in 0...4
      self.moves[i] = attackMoves[i]
      self.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PHOENIXRELEASE,
  proc { |ability,battler,battle|
    attackMoves = [Pokemon::Move.new(:BLASTBURN), Pokemon::Move.new(:AEROBLAST)]
    for i in 0...2
      self.moves[i] = attackMoves[i]
      self.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:PHOENIXRELEASE,
  proc { |ability,user,target,move,battle|
    next if !target.fainted?
    battle.pbShowAbilitySplash(target)
    battle.pbDisplay(_INTL("{1}'s reviving power spread out!",target.name))
    battle.eachInTeamFromBattlerIndex(user.index) do |pkmn,i|
      next if i == 0
      fainted = pkmn.fainted?
      battle.pbDisplay(_INTL("{1} was revived and had its HP fully restored!", pkmn.name)) if fainted
      pkmn.heal_HP
      pkmn.heal_status
      battle.scene.pbRefresh if !fainted
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GOODASGOLD,
  proc { |ability,battler,battle|
    pbBGMFade(0.2)
    $game_system.bgm_play_internal(pbResolveAudioFile("A Trap With No Return"),0)
  }
)

BattleHandlers::MoveImmunityTargetAbility.add(:GOODASGOLD,
  proc { |ability,user,target,move,type,battle|
    next false if !move.statusMove?
    next false if target == user
    next false if target.hasMoldBreaker?
    battle.pbShowAbilitySplash(target)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("It doesn't affect {1}...", target.pbThis(true)))
    else
      battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
         target.pbThis, target.abilityName, move.name))
    end
    battle.pbHideAbilitySplash(target)
  next true
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:INFINITESPACE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    next false if target.damageState.critical
    mults[:final_damage_multiplier] = 0
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:KINGOFSPACE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} opened its domain, Malevolent Shrine!",battler.pbThis))
    battler.pbRaiseStatStageByAbility(:ACCURACY,6,battler)
    battler.raiseCritRate(3)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:HUGEPOWER,:MOUNTAINCRUSHER)

BattleHandlers::TargetAbilityOnHit.add(:MOUNTAINCRUSHER,
  proc { |ability,user,target,move,battle|
    next if target.hp <= 0 || target.fainted?
    case move.type
    when :NORMAL
      num = target.effects[PBEffects::NormalResistance] += 1
      type = "Normal"
    when :WATER
      num = target.effects[PBEffects::WaterResistance] += 1
      type = "Water"
    when :ELECTRIC
      num = target.effects[PBEffects::ElectricResistance] += 1
      type = "Electric"
    when :GRASS
      num = target.effects[PBEffects::GrassResistance] += 1
      type = "Grass"
    when :ICE
      num = target.effects[PBEffects::IceResistance] += 1
      type = "Ice"
    when :FIGHTING
      num = target.effects[PBEffects::FightingResistance] += 1
      type = "Fighting"
    when :POISON
      num = target.effects[PBEffects::PoisonResistance] += 1
      type = "Poison"
    when :GROUND
      num = target.effects[PBEffects::GroundResistance] += 1
      type = "Ground"
    when :FLYING
      num = target.effects[PBEffects::FlyingResistance] += 1
      type = "Flying"
    when :PSYCHIC
      num = target.effects[PBEffects::PsychicResistance] += 1
      type = "Psychic"
    when :BUG
      num = target.effects[PBEffects::BugResistance] += 1
      type = "Bug"
    when :ROCK
      num = target.effects[PBEffects::RockResistance] += 1
      type = "Rock"
    when :DRAGON
      num = target.effects[PBEffects::DragonResistance] += 1
      type = "Dragon"
    when :DARK
      num = target.effects[PBEffects::DarkResistance] += 1
      type = "Dark"
    when :STEEL
      num = target.effects[PBEffects::SteelResistance] += 1
      type = "Steel"
    when :FAIRY
      num = target.effects[PBEffects::FairyResistance] += 1
      type = "Fairy"
    when :FIRE
      num = target.effects[PBEffects::FireResistance] += 1
      type = "Fire"
    end
    battle.pbShowAbilitySplash(target)
    if num >= 3
      battle.pbDisplay(_INTL("{1} adapted and became immune to {2} type attacks!",target.pbThis,type))
    else
      battle.pbDisplay(_INTL("{1} adapted and became more resistant to {2} type attacks!",target.pbThis,type))
    end
    target.pbRecoverHP(num*target.totalhp/16)
    battle.pbHideAbilitySplash(target)
  }
)
  
BattleHandlers::MoveImmunityTargetAbility.add(:MOUNTAINCRUSHER,
  proc { |ability,user,target,move,type,battle|
    ret = false
    case type
    when :NORMAL
      ret = target.effects[PBEffects::NormalResistance] >= 3
    when :WATER
      ret = target.effects[PBEffects::WaterResistance] >= 3
    when :ELECTRIC
      ret = target.effects[PBEffects::ElectricResistance] >= 3
    when :GRASS
      ret = target.effects[PBEffects::GrassResistance] >= 3
    when :ICE
      ret = target.effects[PBEffects::IceResistance] >= 3
    when :FIGHTING
      ret = target.effects[PBEffects::FightingResistance] >= 3
    when :POISON
      ret = target.effects[PBEffects::PoisonResistance] >= 3
    when :GROUND
      ret = target.effects[PBEffects::GroundResistance] >= 3
    when :FLYING
      ret = target.effects[PBEffects::FlyingResistance] >= 3
    when :PSYCHIC
      ret = target.effects[PBEffects::PsychicResistance] >= 3
    when :BUG
      ret = target.effects[PBEffects::BugResistance] >= 3
    when :ROCK
      ret = target.effects[PBEffects::RockResistance] >= 3
    when :DRAGON
      ret = target.effects[PBEffects::DragonResistance] >= 3
    when :DARK
      ret = target.effects[PBEffects::DarkResistance] >= 3
    when :STEEL
      ret = target.effects[PBEffects::SteelResistance] >= 3
    when :FAIRY
      ret = target.effects[PBEffects::FairyResistance] >= 3
    when :FIRE
      ret = target.effects[PBEffects::FireResistance] >= 3
    end
    if ret
      battle.pbShowAbilitySplash(target)
      battle.pbDisplay(_INTL("{1} is immune to the attack!",target.pbThis))
      battle.pbHideAbilitySplash(target)
    end
    next ret
  }
)

BattleHandlers::DamageCalcTargetAbility.add(:MOUNTAINCRUSHER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mult = 0
    case type
    when :NORMAL
      mult = target.effects[PBEffects::NormalResistance]
    when :WATER
      mult = target.effects[PBEffects::WaterResistance]
    when :ELECTRIC
      mult = target.effects[PBEffects::ElectricResistance]
    when :GRASS
      mult = target.effects[PBEffects::GrassResistance]
    when :ICE
      mult = target.effects[PBEffects::IceResistance]
    when :FIGHTING
      mult = target.effects[PBEffects::FightingResistance]
    when :POISON
      mult = target.effects[PBEffects::PoisonResistance]
    when :GROUND
      mult = target.effects[PBEffects::GroundResistance]
    when :FLYING
      mult = target.effects[PBEffects::FlyingResistance]
    when :PSYCHIC
      mult = target.effects[PBEffects::PsychicResistance]
    when :BUG
      mult = target.effects[PBEffects::BugResistance]
    when :ROCK
      mult = target.effects[PBEffects::RockResistance]
    when :DRAGON
      mult = target.effects[PBEffects::DragonResistance]
    when :DARK
      mult = target.effects[PBEffects::DarkResistance]
    when :STEEL
      mult = target.effects[PBEffects::SteelResistance]
    when :FAIRY
      mult = target.effects[PBEffects::FairyResistance]
    when :FIRE
      mult = target.effects[PBEffects::FireResistance]
    end
    mult = 5 if mult > 5
    mults[:final_damage_multiplier] *= (1-0.2*mult)
    target.damageState.unaffected = true if mult == 5
  }
)

# Despair Challenge (Hitsu)
BattleHandlers::DamageCalcTargetAbility.add(:CHIVALROUSWILL,
  proc { |ability,user,target,move,mults,baseDmg,type|
    target.effects[PBEffects::Endure] = true if move.physicalMove?
    target.effects[PBEffects::Endure] = false if move.specialMove?
    mults[:final_damage_multiplier] *= 0.2 if move.specialMove?
  }
)

BattleHandlers::EOREffectAbility.add(:DESTINYREAPING,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::DestinyReaping] -= 1
    battle.pbDisplay(_INTL("{1} turns remain before a soul is reaped...", [battler.effects[PBEffects::DestinyReaping],0].max))
    if battler.effects[PBEffects::DestinyReaping] <= 0
      opponents = []
      battler.eachOpposing do |b|
        opponents.push(b)
      end
      battle.pbShowAbilitySplash(battler)
      toFaint = opponents.sample
      battle.pbDisplay(_INTL("{1} reaped {2}'s soul!", battler.pbThis, toFaint.pbThis))
      toFaint.hp = 0
      toFaint.pbFaint
      battle.pbHideAbilitySplash(battler)
      battler.effects[PBEffects::DestinyReaping] = 5
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:WEATHERHAVOC,
  proc { |ability,user,targets,move,battle|
    case move.type
    when :ELECTRIC
      battle.pbStartDisaster(user,:Thunderstorm)
    when :WATER
      battle.pbStartDisaster(user,:RisingTides)
    when :EARTH
      battle.pbStartDisaster(user,:Earthquakes)
    when :FIRE
      battle.pbStartDisaster(user,:Heatwave)
    end
  }
)

BattleHandlers::TargetAbilityOnHit.add(:LOOMINGFRAILTY,
  proc { |ability,user,target,move,battle|
    # NOTE: This ability has a 50% chance of triggering, not a 50% chance of
    #       inflicting a status condition. It can try (and fail) to inflict a
    #       status condition that the user is immune to.
    next if battle.pbRandom(100)>=50
    r = battle.pbRandom(3)
    next if r==0 && user.asleep?
    next if r==1 && user.poisoned?
    next if r==2 && user.paralyzed?
    battle.pbShowAbilitySplash(target)
    if user.affectedByPowder?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH) &&
       user.affectedByContactEffect?(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      case r
      when 0
        if user.pbCanSleep?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} made {3} fall asleep!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbSleep(msg)
        end
      when 1
        if user.pbCanPoison?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} poisoned {3}!",target.pbThis,
               target.abilityName,user.pbThis(true))
          end
          user.pbPoison(target,msg)
        end
      when 2
        if user.pbCanParalyze?(target,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
          msg = nil
          if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            msg = _INTL("{1}'s {2} paralyzed {3}! It may be unable to move!",
               target.pbThis,target.abilityName,user.pbThis(true))
          end
          user.pbParalyze(target,msg)
        end
      end
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::EOREffectAbility.add(:FOCUSWILL,
  proc { |ability,battler,battle|
    battler.effects[PBEffects::FocusWill] = battler.tookDamage
    battle.pbDisplay(_INTL("{1} has greater accuracy for its attack next turn!",battler.pbThis)) if battler.tookDamage
  }
)

BattleHandlers::AccuracyCalcUserAbility.add(:FOCUSWILL,
  proc { |ability,mods,user,target,move,type|
    mods[:accuracy_multiplier] *= 1.2 if user.effects[PBEffects::FocusWill]
  }
)

BattleHandlers::EOREffectAbility.add(:TIMEACCELERATION,
  proc { |ability,battler,battle|
    # A Pokémon's turnCount is 0 if it became active after the beginning of a
    # round
    if battler.turnCount <= 3 && battler.turnCount > 0
      battle.pbShowAbilitySplash(battler)
      battler.pbOwnSide.effects[PBEffects::MadeInHeaven] += battler.turnCount
      battler.pbOpposingSide.effects[PBEffects::MadeInHeaven] -= battler.turnCount
      case battler.turnCount
      when 1
        battle.pbDisplay(_INTL("Time begins to accelerate!"))
      when 2
        battle.pbDisplay(_INTL("Time accelerates further!"))
      when 3
        battle.pbDisplay(_INTL("Time accelerates to the limit!"))
      end
      battle.pbHideAbilitySplash(battler)
    elsif battler.turnCount >= 3
      battle.pbDisplay(_INTL("The flow of time is at the limit."))
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:TIMEACCELERATION,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:final_damage_multiplier] *= (user.pbSpeed/target.pbSpeed)/2
  }
)

BattleHandlers::TargetAbilityOnHit.add(:BITESTHEDUST,
  proc { |ability,user,target,move,battle|
    battle.pbShowAbilitySplash(target)
    user.pbReduceHP(target.lastHPLostFromFoe*1.5,false)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
         target.pbThis(true),target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:BITESTHEDUST,
  proc { |ability,user,targets,move,battle|
    damageDealt = 0
    targets.each { |t| damageDealt+=t.lastHPLostFromFoe }
    next if damageDealt <= 0    
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("The bomb set by {1} exploded!",user.pbThis))
    targets.each do |target|
      next if target.lastHPLostFromFoe <= 0
      target.pbReduceHP(target.lastHPLostFromFoe*0.5,false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:LIFESUCKER,
  proc { |ability,user,targets,move,battle|
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user)
    battle.pbDisplay(_INTL("{1} restored some hp!",user.pbThis))
    targets.each do |target|
      user.pbRecoverHPFromDrain(target.lastHPLostFromFoe*0.5,target,false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:PARALLELPROTECTION,
  proc { |ability,user,targets,move,battle|
    battle.pbShowAbilitySplash(user)
    if user.effects[PBEffects::Substitute]>0
      user.effects[PBEffects::Substitute] += user.totalhp/2
      battle.pbAnimation(:SUBSTITUTE, user, targets)
      battle.pbDisplay(_INTL("{1} increased the hp of its substitute!",user.pbThis))
    else
      subLife = user.totalhp/2
      subLife = 1 if subLife < 1
      user.effects[PBEffects::Trapping]     = 0
      user.effects[PBEffects::TrappingMove] = nil
      user.effects[PBEffects::Substitute]   = subLife
      battle.pbAnimation(:SUBSTITUTE, user, targets)
      battle.pbDisplay(_INTL("{1} put in a substitute using a clone from another dimension!",user.pbThis))
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::DamageCalcTargetAbility.copy(:MOUNTAINCRUSHER,:PARALLELPROTECTION,
                                              :JOHTOSDRACO,:HOENNSIRON,
                                              :SINNOHSEARTH,:GALARSFLAME,
                                              :UNOVASDREAD, :UNOVASINSECT)

BattleHandlers::TargetAbilityOnHit.add(:CALAMATICMISFORTUNE,
  proc { |ability,user,target,move,battle|
    battle.pbShowAbilitySplash(target)
    user.pbReduceHP(target.totalhp/4,false)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1} is hurt!",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1} is hurt by {2}'s {3}!",user.pbThis,
         target.pbThis(true),target.abilityName))
    end
    battle.pbHideAbilitySplash(target)
  }
)

# Arc Suit Abilities (also Despair Challenge)
BattleHandlers::AbilityOnSwitchIn.add(:JOHTOSDRACO,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbOwnSide.effects[PBEffects::DamageIncrease] += 0.1
    battler.pbOwnSide.effects[PBEffects::DamageReduction] += 0.2
    battle.pbDisplay(_INTL("{1} granted its side a damage increase and damage reduction!",battler.pbThis))
#    abil = (battler.passive) ? battler.passive.id : battler.ability.id
    case ability
    when :JOHTOSDRACO
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::DragonDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Dragon type attacks!",b.pbThis))
        else
          b.effects[PBEffects::DragonResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Dragon type attacks!",battler.pbThis))
    when :HOENNSIRON
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::SteelDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Steel type attacks!",b.pbThis))
        else
          b.effects[PBEffects::SteelResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Steel type attacks!",battler.pbThis))
    when :SINNOHSEARTH
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::GroundDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Ground type attacks!",b.pbThis))
        else
          b.effects[PBEffects::GroundResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Ground type attacks!",battler.pbThis))
    when :GALARSFLAME, :JOHTOSFLAME
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::FireDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Fire type attacks!",b.pbThis))
        else
          b.effects[PBEffects::FireResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Fire type attacks!",battler.pbThis))
    when :UNOVASDREAD
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::DarkDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Dark type attacks!",b.pbThis))
        else
          b.effects[PBEffects::DarkResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Dark type attacks!",battler.pbThis))
    when :UNOVASINSECT
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::BugDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Bug type attacks!",b.pbThis))
        else
          b.effects[PBEffects::BugResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Bug type attacks!",battler.pbThis))
    when :JOHTOSSKY, :KANTOSSKY
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::FlyingDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Flying type attacks!",b.pbThis))
        else
          b.effects[PBEffects::FlyingResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Flying type attacks!",battler.pbThis))
      if ability == :KANTOSSKY
        battle.pbHideAbilitySplash(battler)
        BattleHandlers.triggerAbilityOnSwitchIn(:GRANDENTRY2,battler,battle)
        BattleHandlers.triggerAbilityOnSwitchIn(:SMARTENTRY2,battler,battle)
      end
    when :KANTOSSTONE
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::RockDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Rock type attacks!",b.pbThis))
        else
          b.effects[PBEffects::RockResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Rock type attacks!",battler.pbThis))
      if ability == :KANTOSSTONE
        battle.pbHideAbilitySplash(battler)
        BattleHandlers.triggerAbilityOnSwitchIn(:FIERCEENTRY2,battler,battle)
      end
    when :KANTOSSPLASH
      battle.eachBattler do |b|
        if b.opposes?(battler)
          next if b.damageState.substitute
          b.effects[PBEffects::WaterDebuff] += 1
          battle.pbDisplay(_INTL("{1} became weaker to Water type attacks!",b.pbThis))
        else
          b.effects[PBEffects::WaterResistance] += 1
        end
      end
      battle.pbDisplay(_INTL("{1}'s side because more resistant to Water type attacks!",battler.pbThis))
      if ability == :KANTOSSPLASH
        battle.pbHideAbilitySplash(battler)
        BattleHandlers.triggerAbilityOnSwitchIn(:GRANDENTRY2,battler,battle)
        BattleHandlers.triggerAbilityOnSwitchIn(:SHARPENTRY3,battler,battle)
      end
    end
    battle.pbHideAbilitySplash(battler)
    # Breaking the 4 move limit
    extraMoves = {
      :JOHTOSDRACO => :DOUTRAGE,
      :JOHTOSFLAME => :DSACREDFIRE,
      :JOHTOSSKY => :DAEROBLAST,
      :KANTOSSKY => :DHURRICANE,
      :KANTOSSTONE => :DROCKSLIDE,
    }
    extraMove = extraMoves[ability]
    if extraMove && !battler.pbHasMove?(extraMove)
      battler.moves.push(PokeBattle_Move.from_pokemon_move(battle,Pokemon::Move.new(extraMove)))
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.copy(:JOHTOSDRACO,:GALARSFLAME,:HOENNSIRON,
                                      :SINNOHSEARTH,:UNOVASDREAD,:UNOVASINSECT,
                                      :JOHTOSFLAME,:JOHTOSSKY,:KANTOSSKY,
                                      :KANTOSSTONE,:KANTOSSPLASH)

BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:JOHTOSDRACO,:SINNOHSEARTH,
                                            :GALARSFLAME)

BattleHandlers::UserAbilityEndOfMove.add(:GALARSFLAME,
  proc { |ability,user,targets,move,battle|
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1 if !move.syncMove?
  }
)

BattleHandlers::CriticalCalcUserAbility.add(:SINNOHSEARTH,
  proc { |ability,user,target,c|
    next 99
  }
)

# Make sure Sync Energy is increased (Arc Lance, Steven + Cynthia defined later)
BattleHandlers::UserAbilityEndOfMove.copy(:GALARSFLAME,:UNOVASDREAD,
                                          :UNOVASINSECT,:JOHTOSFLAME,
                                          :JOHTOSSKY,:KANTOSSKY,
                                          :KANTOSSTONE,:KANTOSSPLASH)
                                          
# Arc Suit Lance
BattleHandlers::MoveBaseTypeModifierAbility.add(:JOHTOSDRACO,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:DRAGON)
    move.powerBoost = true
    next :DRAGON
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:JOHTOSDRACO)

BattleHandlers::UserAbilityOnHit.add(:JOHTOSDRACO,
  proc { |ability,user,target,move,battle|
    next if target && !target.opposes?(user)
    if move.physicalMove? 
      battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
      if target.pbCanLowerStatStage?(:DEFENSE,user)
        target.pbLowerStatStageByAbility(:DEFENSE,6,user,false)
      else
        battle.pbDisplay(_INTL("{1}'s Defense couldn't be lowered!",target.pbThis))
      end
      battle.pbHideAbilitySplash(user)
    elsif move.specialMove?
      battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
      if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user)
        target.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,6,user,false)
      else
        battle.pbDisplay(_INTL("{1}'s Special Defense couldn't be lowered!",target.pbThis))
      end
      battle.pbHideAbilitySplash(user)
    end
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:JOHTOSDRACO,
  proc { |ability,user,targets,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:GALARSFLAME,user,targets,move,battle)
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRecoverHP(user.totalhp/16)
    battle.pbDisplay(_INTL("{1} restored some health!",user.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

# Arc Suit Steven
BattleHandlers::TargetAbilityOnHit.add(:HOENNSIRON,
  proc { |ability,user,target,move,battle|
    next if !target.canHeal?
    hpGain = target.totalhp/16
    hpGain = (hpGain*1.3).floor if target.hasActiveItem?(:BIGROOT)
    battle.pbShowAbilitySplash(target,false,true,_INTL("Triage Tank"))
    target.pbRecoverHP(hpGain)
    battle.pbDisplay(_INTL("{1} healed some of its HP!",target.pbThis))
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HOENNSIRON,
  proc { |ability,user,targets,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:GALARSFLAME,user,targets,move,battle)
    user.increasePhStacks(1)
    user.eachAlly { |b| b.increasePhStacks(1) if !b.opposes?(user) }
  }
)

# Arc Suit Cynthia
BattleHandlers::AbilityOnWeatherChange.add(:SINNOHSEARTH,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.weather != :Sandstorm
    battle.pbStartZone(battler, :Ground)
    battle.pbDisplay(_INTL("The Ground Zone was extended!"))
    battle.pbHideAbilitySplash(battler)
    battle.field.zoneDuration = 8
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SINNOHSEARTH,
  proc { |ability,user,targets,move,battle|
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1
    next if (battle.pbAllFainted?(user.idxOpposingSide) || !move.statusMove? ||
            move.trainerMove? || user.effects[PBEffects::PassiveTriggered])
    battle.pbShowAbilitySplash(user,false,true,_INTL("Unbending Pride"))
    user.pbRaiseStatStageByAbility(:ATTACK, 6, user, false)
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1
    battle.pbDisplay(_INTL("{1} increased its side's Sync Energy by 1!", user.pbThis))
    battle.pbHideAbilitySplash(user)
    user.effects[PBEffects::PassiveTriggered] = true
  }
)

# Arc Suit N
BattleHandlers::UserAbilityOnHit.add(:UNOVASDREAD,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    increment = -target.stages[:ACCURACY]
    next if increment <= 0
    increment.times do
      stat = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK,
              :SPECIAL_DEFENSE, :SPEED].sample
      target.pbLowerStatStage(stat,1,user) if target.pbCanLowerStatStage?(stat,user)
    end
  }
)

# Arc Suit Alder
BattleHandlers::MoveBaseTypeModifierAbility.add(:UNOVASINSECT,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:BUG)
    move.powerBoost = true
    next :BUG
  }
)

BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:UNOVASINSECT)
BattleHandlers::CriticalCalcUserAbility.copy(:SINNOHSEARTH,:UNOVASINSECT)

BattleHandlers::AbilityOnZoneChange.add(:UNOVASINSECT,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.zone != :Bug
    battle.pbShowAbilitySplash(battler,false,true,GameData::Ability.try_get(ability).name)
    battler.increaseSpStacks(1)
    battle.pbHideAbilitySplash(battler)
  }
)

# Arc Suit Silver (also has Stench-like effect)
BattleHandlers::TargetAbilityOnHit.add(:JOHTOSFLAME,
  proc { |ability,user,target,move,battle|
    battle.pbShowAbilitySplash(target,false,true,"Touch at Your Own Peril")
    user.pbLowerStatStageByAbility(:ATTACK, 2, target, false)
    user.pbLowerStatStageByAbility(:SPECIAL_ATTACK, 2, target, false)
    battle.pbHideAbilitySplash(target)
    
    battle.pbShowAbilitySplash(target,false,true,"Team Luck Reaction")
    stat = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK,
             :SPECIAL_DEFENSE, :SPEED].sample
    target.pbRaiseStatStageByAbility(stat, 2, target, false)
    battle.eachBattler do |b|
      next if b.opposes?(target) || b == target
      b.pbRaiseStatStageByAbility(stat, 2, target, false)
    end
    battle.pbHideAbilitySplash(target)
    
    BattleHandlers.triggerTargetAbilityOnHit(:AUTOHEAL, user, target, move, battle)  
  }
)

# Arc Suit Ethan (also has Go Viral)
BattleHandlers::UserAbilityOnHit.add(:JOHTOSSKY,
  proc { |ability,user,target,move,battle|
    next if move.syncMove?
    if move.statusMove? && move.pp == move.total_pp - 1
      battle.pbShowAbilitySplash(user,false,true,_INTL("Swirling Storm"))
      user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK, 6, user, false)
      user.raiseCritRate(3)
      battle.pbHideAbilitySplash(user)
    else
      battle.pbShowAbilitySplash(user,false,true,_INTL("Shining Silver Soul"))
      if battle.field.zone != :Flying && move.pp == move.total_pp - 1
        battle.pbStartZone(user, :Flying)
      end
      user.increaseSyStacks(2)
      target.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,3,user,false)
      battle.pbHideAbilitySplash(user)
      next if target.status == :NONE
      BattleHandlers.triggerUserAbilityOnHit(:UNFORTUNATESTRIKE,user,target,move,battle)
    end
  }
)

# Arc Suit Blue
BattleHandlers::CriticalCalcUserAbility.copy(:SINNOHSEARTH,:KANTOSSKY)
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:KANTOSSKY)

# Arc Suit Brock
BattleHandlers::CriticalCalcUserAbility.copy(:SINNOHSEARTH,:KANTOSSTONE)
BattleHandlers::TargetAbilityOnHit.add(:KANTOSSTONE,
  proc { |ability,user,target,move,battle|
    next if (target.hp > target.totalhp / 2) || target.effects[PBEffects::Endure]
    target.effects[PBEffects::Endure] = true
    battle.pbDisplay(_INTL("{1} braced itself!", target.pbThis))    
  }
)
BattleHandlers::UserAbilityOnHit.add(:KANTOSSTONE,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerTargetAbilityOnHit(:AUTOHEAL, target, user, move, battle)  
  }
)
BattleHandlers::EORHealingAbility.add(:KANTOSSTONE,
  proc { |ability,battler,battle|
    if battler.hp <= battler.totalhp / 2
      BattleHandlers.triggerTargetAbilityOnHit(:AUTOHEAL, battler, battler, nil, battle)
    end
    next if battler.status != :SLEEP
    abilName = GameData::Ability.try_get(ability).name
    battle.pbShowAbilitySplash(battler, false, true, abilName)
    battler.pbCureStatus(PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
    if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s {2} woke it up!",battler.pbThis,abilName))
    end
    battle.pbHideAbilitySplash(battler)
  }
)

# Arc Suit Misty (abilities defined elsewhere)
