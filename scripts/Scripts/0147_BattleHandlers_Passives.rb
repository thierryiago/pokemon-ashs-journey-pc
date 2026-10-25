#===============================================================================
# Passive Handlers by Luc-ker
#===============================================================================
# UserEndOfMove Passive handlers
#===============================================================================
# Notes:
# - Some Passives will use "GameData::Ability.try_get(ability).name" to get the
#   name of an ability. This is because the player is able to obtain them.
# - Others will have the name hardcoded; this is for enemy trainer passives in
#   Sync/Titan challenges and can't be normally obtained by the player.
#   Also, they tend to be a collection of passives and implementing them this
#   way would make the code more readable and reusable.
#===============================================================================
# Healing Effects
BattleHandlers::UserAbilityEndOfMove.add(:ACTIVEHEALING,
  proc { |ability,user,targets,move,battle|
    next if !user.canHeal?
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    if user.hp == user.totalhp
      battle.pbDisplay(_INTL("{1}'s HP is already full!",user.pbThis))
    else
      user.pbRecoverHP(user.totalhp/50)
      battle.pbDisplay(_INTL("{1} restored some health!",user.pbThis))
    end
    battle.pbHideAbilitySplash(user)
  }
)

# Stat Buffs (Player Passives)
BattleHandlers::UserAbilityEndOfMove.add(:BRAWNGAIN,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:ATTACK,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SHIELDINGSTRIKES,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:DEFENSE,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MINDSWELL,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ACUMEN,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FLEETFEET,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:SPEED,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:PRECISIONGAIN,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0 || !user.pbCanRaiseStatStage?(stat)
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:ACCURACY,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SHIFTYSTRIKER,
  proc { |ability,user,targets,move,battle|
    next if rand(10) > 0 || !user.pbCanRaiseStatStage?(stat)
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.pbRaiseStatStageByAbility(:EVASION,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:EAGLEEYE,
  proc { |ability,user,targets,move,battle|
    next if rand(20) > 0
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    user.raiseCritRate(1)
    battle.pbHideAbilitySplash(user)
  }
)

# Stat Buffs (Enemy Passives)
BattleHandlers::UserAbilityEndOfMove.add(:SHIFTIERSTRIKER,
  proc { |ability,user,targets,move,battle|
    next if battle.pbRandom(2) == 0 # 50% chance to activate
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Shiftier Striker")
    user.pbRaiseStatStageByAbility(:EVASION,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FORCEFIELD,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Force Field")
    user.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    user.eachAlly { |b| b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,user,false) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:AFFLICTERSADVANTAGE,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove? || move.pp != move.total_pp - 1
    battle.pbShowAbilitySplash(user, false, true, "Afflicter's Advantage")
    stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED]
    stats.each do |s|
      user.pbRaiseStatStageByAbility(s,1,user,false)
    end
    user.eachAlly do |b|
      stats.each { |s| b.pbRaiseStatStageByAbility(s,1,user,false) }
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MINDBRACINGAFFLICTION,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove? || move.pp != move.total_pp - 1
    battle.pbShowAbilitySplash(user, false, true, "Mind-Bracing Affliction")
    user.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,4,user,false)
    user.eachAlly { |b| b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,4,user,false) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:POWERCOMBO,
  proc { |ability,user,targets,move,battle|
#    next if battle.pbRandom(100) >= 30 && battler.passive.id == :SSSTEVEN2
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Power Combo")
    user.increasePhStacks(1)
    user.increaseSpStacks(1)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:MINDBRACINGINFLICTION,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Mind-Bracing Infliction")
    user.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,2,user,false)
    user.eachAlly { |b| b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,2,user,false) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:CATALYTICINFLICTION,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove? || move.pp != move.total_pp - 1 ||
      user.pbOwnSide.effects[PBEffects::Tailwind] != 0
    battle.pbShowAbilitySplash(user, false, true, "Catalytic Infliction")
    user.pbOwnSide.effects[PBEffects::Tailwind] = 4
    battle.pbDisplay(_INTL("The Tailwind blew from behind {1}!",user.pbTeam(true)))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:BRAINSTORM,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove? ||
      user.damageState.initialHP > user.totalhp/2
    battle.pbShowAbilitySplash(user, false, true, "Brainstorm")
    user.increaseSpStacks(1)
    user.eachAlly { |b| b.increaseSpStacks(1) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FORTUITOUSX3,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Fortuitous X3")
    3.times do
      stat = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
                :SPEED, :ACCURACY, :EVASION].sample
      user.pbRaiseStatStageByAbility(stat,1,user,false) if user.pbCanRaiseStatStage?(stat,user,self)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HONINGHIT,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Honing Hit")
    user.pbRaiseStatStageByAbility(:ATTACK,2,user,false)
    user.raiseCritRate(1)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SEEKINGHIT,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Seeking Hit")
    user.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,user,false)
    user.raiseCritRate(1)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:BRAINGAIN,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Brain Gain")
    user.increaseSpStacks(1)
    user.eachAlly { |b| b.increaseSpStacks(1) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:PEPRALLY,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Pep Rally")
    user.pbRaiseStatStageByAbility(:SPEED,1,user,false)
    user.eachAlly { |b| b.pbRaiseStatStageByAbility(:SPEED,1,user,false) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:FLEETERFEET,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Fleeter Feet")
    user.pbRaiseStatStageByAbility(:SPEED,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:STRENGTHENINGSTATUS,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Strengthening Status")
    user.increasePhStacks(1)
    user.increaseSpStacks(1)
    user.eachAlly do |b|
      b.increasePhStacks(1)
      b.increaseSpStacks(1)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:JOURNEYFROMPALLET,
  proc { |ability,user,targets,move,battle|
    affected = []
    targets.each { |t| affected.push(t) if !t.noDamageTaken }
    next if affected.length == 0
    battle.pbShowAbilitySplash(user, false, true, "Journey from Pallet")
    user.increaseSpStacks(affected.length)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:PRIDEOFPALLET,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Pride of Pallet")
    user.pbRaiseStatStageByAbility(:DEFENSE,1,user,false)
    user.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    user.eachAlly do |b|
      b.pbRaiseStatStageByAbility(:DEFENSE,1,user,false)
      b.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ATTACKBOOSTERMAX,
  proc { |ability,user,targets,move,battle|
    next if !move.trainerMove?
    battle.pbShowAbilitySplash(user,false,true,_INTL("Attack Booster MAX"))
    user.pbRaiseStatStage(:ATTACK,6,user)
    user.increasePhStacks(1)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ARIAPERFORMANCE,
  proc { |ability,user,targets,move,battle|
    next if user.species != :MELOETTA || move.trainerMove?
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user,false,true,_INTL("{1} Performance",GameData::Type.get(user.type2).real_name))
    case user.form
    when 0
      user.pbRaiseStatStage(:DEFENSE,1,user)
    when 1
      user.pbRaiseStatStage(:SPECIAL_DEFENSE,1,user)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SANDYBRAWNGAIN,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Sandy Brawn Gain")
    user.increasePhStacks(1)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:EVASIVEMANEUVERS,
  proc { |ability,user,targets,move,battle|
    unaffected = []
    targets.each { |t| unaffected.push(t.noDamageTaken) }
    next if !unaffected.include?(false)
    battle.pbShowAbilitySplash(user, false, true, "Evasive Maneusvers")
    user.pbRaiseStatStageByAbility(:EVASION,1,user,false)
    user.eachAlly { |b| b.pbRaiseStatStageByAbility(:EVASION,1,user,false) }
    battle.pbHideAbilitySplash(user)
  }
)

# Stat Debuffs (Enemy Passives)
BattleHandlers::UserAbilityEndOfMove.add(:BADBREAK,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove?
    stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
            :SPEED, :ACCURACY, :EVASION]
    battle.pbShowAbilitySplash(user, false, true, "Bad Break")
    user.eachOpposing { |b| b.pbLowerStatStageByAbility(stats.sample,1,user,false) }
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:LOVEOFPALLET,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove?
    affected = []
    targets.each { |t| affected.push(t) if !t.noDamageTaken }
    next if affected.length == 0
    battle.pbShowAbilitySplash(user,false,true,_INTL("Love of Pallet"))
    affected.each do |b|
      b.pbLowerStatStageByAbility(:ATTACK,1,user,false)
      b.pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
      b.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:ILLUMINATINGWHITEBLAZE,
  proc { |ability,user,targets,move,battle|
    next if !move.statusMove? || move.trainerMove?
    affected = []
    targets.each { |t| affected.push(t) if !t.noDamageTaken }
    next if affected.length == 0
    battle.pbShowAbilitySplash(user, false, true, "Illuminating White Blaze")
    affected.each do |b|
      next if b.effects[PBEffects::FireDebuff] >= 3
      b.effects[PBEffects::FireDebuff] += 1
      battle.pbDisplay(_INTL("{1} became weaker to Fire type attacks!",b.pbThis))
    end
    battle.pbHideAbilitySplash(user)
  }
)

# Other
BattleHandlers::UserAbilityEndOfMove.add(:MPREGAIN,
  proc { |ability,user,targets,move,battle|
    next if battle.wildBattle? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "MP Regain")
    moves = user.moves.select { |m| m.trainerMove? }
    restored = false
    moves.each do |m|
      next if m.pp == m.total_pp
      m.pp += 1
      restored = true
    end
    if restored
      msg = _INTL("{1} restored PP to {2}'s trainer move!",
                  user.pbThis, battle.pbGetOwnerName(user.index))
    else
      msg = _INTL("{1}'s trainer move is already at maximum PP.",
                  battle.pbGetOwnerName(user.index))
    end
    battle.pbDisplay(msg)
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# TargetOnHit Passive handlers
#===============================================================================
# Player Passives
BattleHandlers::TargetAbilityOnHit.add(:BEEFUP,
  proc { |ability,user,target,move,battle|
    next if rand(10) > 0 || target.fainted?
    battle.pbShowAbilitySplash(target, false, true, GameData::Ability.try_get(ability).name)
    target.pbRaiseStatStageByAbility(:ATTACK,1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TOUGHENUP,
  proc { |ability,user,target,move,battle|
    next if rand(10) > 0 || target.fainted?
    battle.pbShowAbilitySplash(target, false, true, GameData::Ability.try_get(ability).name)
    target.pbRaiseStatStageByAbility(:DEFENSE,1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:SOUPUP,
  proc { |ability,user,target,move,battle|
    next if rand(10) > 0 || target.fainted?
    battle.pbShowAbilitySplash(target, false, true, GameData::Ability.try_get(ability).name)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TIGHTENUP,
  proc { |ability,user,target,move,battle|
    next if rand(10) > 0 || target.fainted?
    battle.pbShowAbilitySplash(target, false, true, GameData::Ability.try_get(ability).name)
    target.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:LOOKALIVE,
  proc { |ability,user,target,move,battle|
    next if rand(10) > 0 || target.fainted?
    battle.pbShowAbilitySplash(target, false, true, GameData::Ability.try_get(ability).name)
    target.pbRaiseStatStageByAbility(:EVASION,1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

# Enemy Passives
BattleHandlers::TargetAbilityOnHit.add(:LOOKALIVE2,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    battle.pbShowAbilitySplash(target, false, true, "Look Alive")
    target.pbRaiseStatStageByAbility(:EVASION,1,target,false)
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:TEAMSHOUT,
  proc { |ability,user,target,move,battle|
    next if target.fainted?
    battle.pbShowAbilitySplash(target, false, true, "Team Shout")
    user.eachOpposing do |b|
      b.pbRaiseStatStageByAbility(:ATTACK,1,target,false) if b.pbCanRaiseStatStage?(:ATTACK,target)
      next if !b.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
      b.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target,false)
    end
    battle.pbHideAbilitySplash(target)
  }
)

BattleHandlers::TargetAbilityOnHit.add(:AUTOHEAL,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || (target.hp > target.totalhp / 2)
    move_id = nil
    min_pp = 2
    moved = (target.lastRoundMoved == battle.turnCount)
    case target.passive.id
    when :NCELIO
      move_id = :MORNINGSUN
      abil_name = "Gentle Morning Sun"
    when :NCSELENE
      move_id = :MOONLIGHT
      abil_name = "Warm Moonlight"
    when :JOHTOSFLAME
      move_id = :RECOVER
      abil_name = "Everlasting Rainbow"
      min_pp = 4
    when :KANTOSSTONE
      move_id = :REST
      abil_name = "Rock-Solid Rest"
      min_pp = 4
    end
    next if !move_id
    move_idx = target.pbGetMoveIdx(move_id)
    next if move_idx == -1 || target.moves[move_idx].pp < min_pp
    battle.pbShowAbilitySplash(target, false, true, abil_name)
    target.pbUseMoveSimple(move_id, move_idx)
    case target.passive.id
    when :NCELIO, :KANTOSSTONE
      target.increasePhStacks(2)
    when :NCSELENE
      target.increaseSpStacks(2)
    end
    target.moves[move_idx].pp -= min_pp
    target.lastRoundMoved -= 1 if !moved
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# OnSwitchIn Passive handlers
#===============================================================================
### Own stat increases (Player passives) ###
BattleHandlers::AbilityOnSwitchIn.add(:FIERCEENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:ATTACK,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SENTRYENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:DEFENSE,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRANDENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WISEENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:SPECIAL_DEFENSE,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SPEEDYENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:SPEED,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PINPOINTENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:ACCURACY,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AGILEENTRY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battler.pbRaiseStatStageByAbility(:EVASION,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

### Enemy Passives ###
# Attack
BattleHandlers::AbilityOnSwitchIn.add(:FIERCEENTRY2,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Fierce Entry 2")
    battler.pbRaiseStatStageByAbility(:ATTACK,2,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:FIERCEENTRY6,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Fierce Entry 6")
    battler.pbRaiseStatStageByAbility(:ATTACK,6,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

# Sp. Attack
BattleHandlers::AbilityOnSwitchIn.add(:GRANDENTRY2,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Grand Entry 2")
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,2,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:GRANDENTRY6,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Grand Entry 6")
    battler.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,6,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

# Speed
BattleHandlers::AbilityOnSwitchIn.add(:DEBUTDASH,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Debut Dash")
    battler.pbRaiseStatStageByAbility(:SPEED,1,battler,false)
    battler.eachAlly { |b| b.pbRaiseStatStageByAbility(:SPEED,1,battler,false) }
    battle.pbHideAbilitySplash(battler)
  }
)

# Crit
BattleHandlers::AbilityOnSwitchIn.add(:SHARPENTRY3,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Sharp Entry 3"))
    battler.raiseCritRate(3)
    battle.pbHideAbilitySplash(battler)
  }
)

# SMUP
BattleHandlers::AbilityOnSwitchIn.add(:SMARTENTRY2,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Smart Entry 2")
    battler.increaseSpStacks(2)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SMARTSTART,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Smart Start")
    battler.increaseSpStacks(1)
    battler.eachAlly { |b| b.increaseSpStacks(1) }
    battle.pbHideAbilitySplash(battler)
  }
)

### Opp stat decreases ###
BattleHandlers::AbilityOnSwitchIn.add(:TERRIFY,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:ATTACK,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ENFEEBLE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:DEFENSE,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DISCOURAGE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BEFUDDLE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TRIPWIRE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:SPEED,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:BEDAZZLE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:ACCURACY,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IMPOSE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, GameData::Ability.try_get(ability).name)
    battle.eachOtherSideBattler(battler.index) do |b|
      next if !b.near?(battler)
      b.pbLowerStatStageByAbility(:EVASION,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:TRIPPINGWIRE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Tripping Wire")
    battle.eachOtherSideBattler(battler.index) do |b|
      b.pbLowerStatStageByAbility(:SPEED,1,battler,false)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

### Weather ###
BattleHandlers::AbilityOnSwitchIn.add(:SUNBURST,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sun, battler, battle, false, 3)
    battle.pbDisplay(_INTL("The sun will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNPOUR,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Rain, battler, battle, false, 3)
    battle.pbDisplay(_INTL("The rain will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:COLDFRONT,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Hail, battler, battle, false, 3)
    battle.pbDisplay(_INTL("The hailstorm will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SANDKICKER,
  proc { |ability,battler,battle|
    pbBattleWeatherAbility(:Sand, battler, battle, false, 3)
    battle.pbDisplay(_INTL("The sandstorm will only last 3 turns!"))
  }
)

### Terrain ###
BattleHandlers::AbilityOnSwitchIn.add(:CONDUCTIVEPLANT,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Electric, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:VERDANTTURF,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Grass
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Grass, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WEIRDSTASIS,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Psychic
    battle.pbShowAbilitySplash(battler)
    battle.pbStartTerrain(battler, :Psychic, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartTerrain.
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:LOWKEYMELANCHOLY,
  proc { |ability,battler,battle|
    next if battle.field.terrain == :Electric
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Low-Key Melancholy"))
    battle.pbStartTerrain(battler, :Electric)
    battle.pbDisplay(_INTL("The Electric Terrain was extended!"))
    battle.field.terrainDuration = 8
  }
)

### Zone ###
BattleHandlers::AbilityOnSwitchIn.add(:SIMPLESETUP,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Normal
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Normal, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Normal Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ARCTICARRIVAL,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Ice
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Ice, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Ice Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PASSIONAURA,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Fighting
    duration = (ability == :SSCYNTHIA3) ? 5 : 3
    abilName = (ability == :SSCYNTHIA3) ? "Passion Aura" : nil
    battle.pbShowAbilitySplash(battler, false, true, abilName)
    battle.pbStartZone(battler, :Fighting, true, duration)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    if duration == 3
      battle.pbDisplay(_INTL("The Fighting Zone will only last 3 turns!"))
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WASTELAND,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Poison
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Poison, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Poison Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DOWNTOEARTH,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Ground
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Ground, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Ground Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:LANDINGPAD,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Flying
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Flying, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Flying Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:WONDERWORLD,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Bug
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Bug, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Bug Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:CLIMBTOEDGE,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Rock
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Rock, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Rock Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:HAUNTEDFALLING,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Ghost
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Ghost, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Ghost Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:DRACODOMAIN,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Dragon
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Dragon, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Dragon Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:UMBRALCALL,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Dark
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Dark, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Dark Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:IRONSURROUNDINGS,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Steel
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Steel, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Steel Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:ETHEREALENTRANCE,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Fairy
    battle.pbShowAbilitySplash(battler)
    battle.pbStartZone(battler, :Fairy, true, 3)
    # NOTE: The ability splash is hidden again in def pbStartZone.
    battle.pbDisplay(_INTL("The Fairy Zone will only last 3 turns!"))
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:AMPEDANDVIBED,
  proc { |ability,battler,battle|
    next if battle.field.zone == :Poison
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Amped and Vibed"))
    battle.pbStartZone(battler, :Poison)
    battle.pbDisplay(_INTL("The Poison Zone was extended!"))
    battle.field.zoneDuration = 8
  }
)

### Gain Effects ###
BattleHandlers::AbilityOnSwitchIn.add(:HEALTHYHEALING,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler, false, true, "Healthy Healing")
    battler.effects[PBEffects::GradualHealing] = true
    battle.pbDisplay(_INTL("{1} gained a restorative aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:QUICKTEMPO,
  proc { |ability,battler,battle|
    next if battler.pbOwnSide.effects[PBEffects::Tailwind] != 0
    battle.pbShowAbilitySplash(battler, false, true, "Quick Tempo")
    battler.pbOwnSide.effects[PBEffects::Tailwind] = 4
    battle.pbDisplay(_INTL("The Tailwind blew from behind {1}!",battler.pbTeam(true)))
    battle.pbHideAbilitySplash(battler)
  }
)

### Master Passives ###
BattleHandlers::AbilityOnSwitchIn.add(:FLAGBEARER,
  proc { |ability,battler,battle|
    battler.pbOwnSide.effects[PBEffects::DamageIncrease] += 0.1
    battler.pbOwnSide.effects[PBEffects::DamageReduction] += 0.2
    case battler.passive.id
    when :SSTRED, :NCBLUE
      abilName = "Kanto Flag Bearer"
    when :SSKRIS, :SSGIOVANNI2
      abilName = "Johto Flag Bearer"
    when :ANNISTEVEN
      abilName = "Hoenn Flag Bearer"
    when :SSCYNTHIA2, :SSCYNTHIA3
      abilName = "Sinnoh Flag Bearer"
    when :ANNIN, :NCROSA, :NCBIANCA
      abilName = "Unova Flag Bearer"
    when :SSSERENA
      abilName = "Kalos Flag Bearer"
    when :ANNILILLIE
      abilName = "Alola Flag Bearer"
    when :NCBEDE
      abilName = "Galar Flag Bearer"
    else
      abilName = "Flag Bearer"
    end
    battle.pbShowAbilitySplash(battler, false, true, abilName)
    battle.pbDisplay(
      _INTL("{1} granted its side a damage increase and damage reduction to all moves!",
            battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    # Extra switch in effects
    case battler.passive.id
    when :ANNILILLIE
      BattleHandlers.triggerAbilityOnSwitchIn(:QUICKTEMPO,battler,battle)
    when :NCBEDE
      BattleHandlers.triggerAbilityOnSwitchIn(:DEBUTDASH,battler,battle)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:PRIDE,
  proc { |ability,battler,battle|
    battler.pbOwnSide.effects[PBEffects::PhysDmgIncrease] += 0.2
    battler.pbOwnSide.effects[PBEffects::PhysDmgReduction] += 0.25
    case battler.passive.id
    when :NCLEAF
      abilName = "Kanto Pride"
    when :SSLYRA, :NCSILVER
      abilName = "Johto Pride"
    when :NCBRENDAN
      abilName = "Hoenn Pride"
    when :NCNATE
      abilName = "Unova Pride"
    when :NCCALEMW, :NCCALEMD
      abilName = "Kalos Pride"
    when :NCELIO
      abilName = "Alola Pride"
    when :NCHOP
      abilName = "Galar Pride"
    else
      abilName = "Pride"
    end
    battle.pbShowAbilitySplash(battler, false, true, abilName)
    battle.pbDisplay(
      _INTL("{1} granted its side a damage increase and damage reduction to physical moves!",
            battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    case battler.passive.id
    when :NCBRENDAN, :NCELIO, :NCHOP
      BattleHandlers.triggerAbilityOnSwitchIn(:FIERCEENTRY2,battler,battle)
    end
  }
)

BattleHandlers::AbilityOnSwitchIn.add(:SPIRIT,
  proc { |ability,battler,battle|
    battler.pbOwnSide.effects[PBEffects::SpecDmgIncrease] += 0.2
    battler.pbOwnSide.effects[PBEffects::SpecDmgReduction] += 0.25
    case battler.passive.id
    when :NCRED
      abilName = "Kanto Spirit"
    when :SSETHAN
      abilName = "Johto Spirit"
    when :NCMAY
      abilName = "Hoenn Spirit"
    when :NCCHEREN
      abilName = "Unova Spirit"
    when :NCSERENAW, :NCSERENAD
      abilName = "Kalos Spirit"
    when :SSLUSAMINE, :SSGLADION, :NCSELENE
      abilName = "Alola Spirit"
    when :NCMARNIE
      abilName = "Galar Spirit"
    else
      abilName = "Spirit"
    end
    battle.pbShowAbilitySplash(battler, false, true, abilName)
    battle.pbDisplay(
      _INTL("{1} granted its side a damage increase and damage reduction to special moves!",
            battler.pbThis))
    battle.pbHideAbilitySplash(battler)
    case battler.passive.id
    when :NCMAY, :NCSELENE
      BattleHandlers.triggerAbilityOnSwitchIn(:GRANDENTRY2,battler,battle)
    when :NCMARNIE
      BattleHandlers.triggerAbilityOnSwitchIn(:SHARPENTRY3,battler,battle)
    end
  }
)

#===============================================================================
# UserOnHit Passive handlers
#===============================================================================
# Stat Boosts
BattleHandlers::UserAbilityOnHit.add(:EVASIVESTRIKE,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken
    battle.pbShowAbilitySplash(user, false, true, "Evasive Strike")
    user.pbRaiseStatStageByAbility(:EVASION,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

# Stat Debuffs
BattleHandlers::UserAbilityOnHit.add(:MINDGAMES,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Mind Games")
    target.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SUNDERING,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Sundering")
    target.pbLowerStatStageByAbility(:DEFENSE,1,user,false)
    target.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:RUTHLESS,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
            :SPEED, :ACCURACY, :EVASION]
    battle.pbShowAbilitySplash(user, false, true, "Ruthless")
    target.pbLowerStatStageByAbility(stats.sample,2,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:PUNISHINGSTRIKE,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Punishing Strike")
    target.pbLowerStatStageByAbility(:DEFENSE,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:TRIPPINGSTRIKE,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Tripping Strike")
    target.pbLowerStatStageByAbility(:SPEED,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:DEFENSEDESTROYER,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Defense Destroyer")
    target.pbLowerStatStageByAbility(:DEFENSE,2,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SUPERSLOWERINGHIT,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted? ||
        !Effectiveness.super_effective?(target.damageState.typeMod)
    battle.pbShowAbilitySplash(user, false, true, "Super Slowering Hit")
    target.pbLowerStatStageByAbility(:SPEED,2,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SATISFIEDSNARL,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Satisfied Snarl")
    target.pbLowerStatStageByAbility(:SPECIAL_ATTACK,2,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:LUCKYSEVEN,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
            :SPEED, :ACCURACY, :EVASION]
    battle.pbShowAbilitySplash(user, false, true, "Lucky Seven")
    stats.each do |s|
      target.pbLowerStatStageByAbility(s,1,user,false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SSROXIE,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted? ||
        !(target.poisoned? || target.paralyzed?)
    battle.pbShowAbilitySplash(user, false, true, GameData::Ability.try_get(ability).name)
    case target.status
    when :POISON
      target.pbLowerStatStageByAbility(:ATTACK,1,user,false)
    when :PARALYSIS
      target.pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:DISARM,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    next if !target.effects[PBEffects::Flinch] &&
            !target.effects[PBEffects::Confusion] && 
            !(target.effects[PBEffects::Trapping]>0)
    battle.pbShowAbilitySplash(user, false, true, "Disarm")
    target.pbLowerStatStageByAbility(:ATTACK,1,user,false)
    target.pbLowerStatStageByAbility(:SPECIAL_ATTACK,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:UNFORTUNATESTRIKE,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE,
            :SPEED, :ACCURACY, :EVASION]
    battle.pbShowAbilitySplash(user, false, true, "Unfortunate Strike")
    target.pbLowerStatStageByAbility(stats.sample,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:DISCOMBOBULATE,
  proc { |ability,user,target,move,battle|
    next if target.noDamageTaken || target.fainted?
    battle.pbShowAbilitySplash(user, false, true, "Discombobulate")
    target.pbLowerStatStageByAbility(:ACCURACY,1,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

# Healing Effects
BattleHandlers::UserAbilityEndOfMove.add(:HEALINGSUN,
  proc { |ability,user,target,move,battle|
    next if !([:Sun, :HarshSun].include?(battle.field.weather)) || user.fullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Healing Sun")
    user.pbRecoverHP(user.totalhp/10)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s Healing Sun restored its HP.",user.pbThis))
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SUNBATHE,
  proc { |ability,user,target,move,battle|
    next if !([:Sun, :HarshSun].include?(battle.field.weather)) || user.sideFullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Sunbathe")
    seenAbilName = false
    if !user.fullHP?
      user.pbRecoverHP(user.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s Sunbathe restored its HP.",user.pbThis))
        seenAbilName = true
      end
    end
    user.eachAlly do |b|
      next if b.fullHP?
      b.pbRecoverHP(b.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH || seenAbilName
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s HP was restored by {2}'s Sunbathe.",b.pbThis,user.pbThis(false)))
        seenAbilName = true
      end
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:REFRESHINGRAIN,
  proc { |ability,user,target,move,battle|
    next if !([:Rain, :HeavyRain].include?(battle.field.weather)) || user.sideFullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Refreshing Rain")
    seenAbilName = false
    if !user.fullHP?
      user.pbRecoverHP(user.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s Refreshing Rain restored its HP.",user.pbThis))
        seenAbilName = true
      end
    end
    user.eachAlly do |b|
      next if b.fullHP?
      b.pbRecoverHP(b.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH || seenAbilName
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s HP was restored by {2}'s Refreshing Rain.",b.pbThis,user.pbThis(false)))
        seenAbilName = true
      end
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:SHOCKRECOVERY,
  proc { |ability,user,target,move,battle|
    next if battle.field.terrain != :Electric || user.fullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Shock Recovery")
    user.pbRecoverHP(user.totalhp/10)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s Shock Recovery restored its HP.",user.pbThis))
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:HAUNTEDHEALING,
  proc { |ability,user,target,move,battle|
    next if battle.field.zone != :Ghost || user.fullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Haunted Healing")
    user.pbRecoverHP(user.totalhp/10)
    if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
      battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    else
      battle.pbDisplay(_INTL("{1}'s Haunted Healing restored its HP.",user.pbThis))
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:BRAWLINGRESTORATION,
  proc { |ability,user,targets,move,battle|
    next if battle.field.zone != :Fighting || user.sideFullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Brawling Restoration")
    seenAbilName = false
    if !user.fullHP?
      user.pbRecoverHP(user.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s Brawling Restoration restored its HP.",user.pbThis))
        seenAbilName = true
      end
    end
    user.eachAlly do |b|
      next if b.fullHP?
      b.pbRecoverHP(b.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH || seenAbilName
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s HP was restored by {2}'s Brawling Restoration.",b.pbThis,user.pbThis(false)))
        seenAbilName = true
      end
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityEndOfMove.add(:UMBRALRESTORATION,
  proc { |ability,user,target,move,battle|
    next if battle.field.zone != :Dark || user.sideFullHP? || move.trainerMove?
    battle.pbShowAbilitySplash(user, false, true, "Umbral Restoration")
    seenAbilName = false
    if !user.fullHP?
      user.pbRecoverHP(user.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s Umbral Restoration restored its HP.",user.pbThis))
        seenAbilName = true
      end
    end
    user.eachAlly do |b|
      next if b.fullHP?
      b.pbRecoverHP(b.totalhp/16)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH || seenAbilName
        battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s HP was restored by {2}'s Umbral Restoration.",b.pbThis,user.pbThis(false)))
        seenAbilName = true
      end
    end
    battle.pbHideAbilitySplash(user)
  }
)

# Inflict Status Condition
BattleHandlers::UserAbilityOnHit.add(:VENOMOUS,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken || target.poisoned?
    battle.pbShowAbilitySplash(user, false, true, "Venomous")
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanPoison?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s Venomous badly poisoned {2}!",user.pbThis,target.pbThis(true))
      end
      target.pbPoison(user,msg,true)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:HASSLINGHIT,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken
    battle.pbShowAbilitySplash(user, false, true, "Hassling Hit")
    if !target.effects[PBEffects::EscapeArtist] && !(target.effects[PBEffects::Trapping]>0)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
      target.effects[PBEffects::TrappingMove] = move.id
      target.effects[PBEffects::TrappingUser] = user.index
      battle.pbDisplay(_INTL("{1} was trapped by {2}!",target.pbThis,user.pbThis(true)))
    end
    target.pbFlinch(user)
    target.pbConfuse(user) if target.pbCanConfuse?(user,true,self)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:GOBSMACK,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken ||
      target.effects[PBEffects::Confusion] > 0
    battle.pbShowAbilitySplash(user, false, true, "Gobsmack")
    target.pbConfuse(user) if target.pbCanConfuse?(user,true,self)
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:SCORCHINGTOUCH,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken || target.burned?
    battle.pbShowAbilitySplash(user, false, true, "Scorching Touch")
    if target.hasActiveAbility?(:SHIELDDUST) && !battle.moldBreaker
      battle.pbShowAbilitySplash(target)
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      end
      battle.pbHideAbilitySplash(target)
    elsif target.pbCanBurn?(user,PokeBattle_SceneConstants::USE_ABILITY_SPLASH)
      msg = nil
      if !PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        msg = _INTL("{1}'s {2} burned {3}!",user.pbThis,user.abilityName,target.pbThis(true))
      end
      target.pbBurn(user,msg)
    end
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:ATTACKTRAP,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken ||
      target.effects[PBEffects::Trapping] > 0
    battle.pbShowAbilitySplash(user, false, true, "Attack Trap")
    if !target.effects[PBEffects::EscapeArtist]
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
      target.effects[PBEffects::TrappingMove] = move.id
      target.effects[PBEffects::TrappingUser] = user.index
      battle.pbDisplay(_INTL("{1} was trapped by {2}!",target.pbThis,user.pbThis(true)))
    end
    battle.pbHideAbilitySplash(user)
  }
)

# Decrease type resistance
BattleHandlers::UserAbilityOnHit.add(:SHIMMERINGWHITESNOW,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken ||
      target.effects[PBEffects::IceDebuff] >= 3
    battle.pbShowAbilitySplash(user,true,false,_INTL("Shimmering White Snow"))
    target.effects[PBEffects::IceDebuff] += 1
    battle.pbDisplay(_INTL("{1} became weaker to Ice type attacks!",target.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:ROARINGWHITELIGHTNING,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken ||
      target.effects[PBEffects::ElectricDebuff] >= 3
    battle.pbShowAbilitySplash(user,true,false,_INTL("Roaring White Lightning"))
    target.effects[PBEffects::ElectricDebuff] += 1
    battle.pbDisplay(_INTL("{1} became weaker to Electric type attacks!",target.pbThis))
    battle.pbHideAbilitySplash(user)
  }
)

BattleHandlers::UserAbilityOnHit.add(:ENTRANCINGMELODY,
  proc { |ability,user,target,move,battle|
    next if target.fainted? || target.noDamageTaken || user.species != :MELOETTA 
    case user.form
    when 0
      next if target.effects[PBEffects::PsychicDebuff] >= 3
      target.effects[PBEffects::PsychicDebuff] += 1
      type = "Psychic"
    when 1
      next if target.effects[PBEffects::FightingDebuff] >= 3
      target.effects[PBEffects::FightingDebuff] += 1
      type = "Fighting"
    else
      next
    end
    battle.pbShowAbilitySplash(user,true,false,_INTL("Entrancing Melody"))
    battle.pbDisplay(_INTL("{1} became weaker to {2} type attacks!",target.pbThis,type))
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# StatLossImmunity Passive handlers
#===============================================================================
BattleHandlers::StatLossImmunityAbility.add(:SANDFORTRESS,
  proc { |ability,battler,stat,battle,showMessages|
    next if battle.field.weather != :Sandstorm
    if showMessages
      battle.pbShowAbilitySplash(battler,false,true,"Sand Fortress")
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered during a Sandstorm!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss during a Sandstorm!",battler.pbThis,"Sand Fortress"))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:SOLARSHIELD,
  proc { |ability,battler,stat,battle,showMessages|
    next if !([:Sun, :HarshSun].include?(battle.field.weather))
    if showMessages
      battle.pbShowAbilitySplash(battler,false,true,"Solar Shield")
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s stats cannot be lowered when it's Sunny!",battler.pbThis))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss when it's Sunny!",battler.pbThis,"Solar Shield"))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

BattleHandlers::StatLossImmunityAbility.add(:FASTRUNNER,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat!=:EVASION
    if showMessages
      battle.pbShowAbilitySplash(battler,false,true,"Fast Runner")
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
# CriticalCalcUser Passive handlers
#===============================================================================
BattleHandlers::CriticalCalcUserAbility.add(:CLUTCHCRITICAL,
  proc { |ability,user,target,c|
    next 99
  }
)

#===============================================================================
# MoveBaseTypeModifier Passive handlers
#===============================================================================
BattleHandlers::MoveBaseTypeModifierAbility.add(:EARTHEN,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:GROUND)
    move.powerBoost = true
    next :GROUND
  }
)

BattleHandlers::MoveBaseTypeModifierAbility.add(:NCROSA,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:PSYCHIC) || !GameData::Type.exists?(:FIGHTING)
    move.powerBoost = true
    next :PSYCHIC if user.form==0
    next :FIGHTING if user.form==1
  }
)

#===============================================================================
# DamageCalcUser Passive handlers
#===============================================================================
BattleHandlers::DamageCalcUserAbility.add(:GOODNIGHTMARE,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if target.status == :SLEEP
  }
)

BattleHandlers::DamageCalcUserAbility.add(:FORTIFY,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:defense_multiplier] *= 1.3 if target.hp <= target.totalhp/2
  }
)

BattleHandlers::DamageCalcUserAbility.add(:POWERRESERVES,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if user.hp <= user.totalhp / 3
      mults[:attack_multiplier] *= 1.3
    end
  }
)

BattleHandlers::DamageCalcUserAbility.add(:HEALTHYPOWERUP,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.5 if user.hp == user.totalhp
  }
)

BattleHandlers::DamageCalcUserAbility.add(:MINDOVERMATTER,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:attack_multiplier] *= 1.3 if user.hp < user.totalhp
  }
)

BattleHandlers::DamageCalcUserAbility.add(:RAGINGRAIN,
  proc { |ability,user,target,move,mults,baseDmg,type|
    if move.specialMove? && [:Rain, :HeavyRain].include?(user.battle.pbWeather) && !target.hasUtilityUmbrella?
      mults[:attack_multiplier] *= 1.5
    end
  }
)

#===============================================================================
# WTZ Change Passive handlers
#===============================================================================
BattleHandlers::AbilityOnTerrainChange.add(:MELEMELEOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.terrain == :None
    if battle.field.terrain == :Electric
      battle.pbDisplay(_INTL("The Electric Terrain was extended!"))
      battle.field.terrainDuration = 8
    end
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Melemele Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Melemele Ocean Breeze boosts its allies!",battler.pbThis))
    battler.increaseSpStacks(1)
    battler.eachAlly do |b|
      b.increaseSpStacks(1)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnZoneChange.add(:MELEMELEOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.zone == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Melemele Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Melemele Ocean Breeze boosts its allies!",battler.pbThis))
    battler.increaseSpStacks(1)
    battler.eachAlly do |b|
      b.increaseSpStacks(1)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnWeatherChange.add(:MELEMELEOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.weather == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Melemele Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Melemele Ocean Breeze boosts its allies!",battler.pbThis))
    battler.increaseSpStacks(1)
    battler.eachAlly do |b|
      b.increaseSpStacks(1)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnTerrainChange.add(:AKALAOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.terrain == :None
    if battle.field.terrain == :Psychic
      battle.pbDisplay(_INTL("The Psychic Terrain was extended!"))
      battle.field.terrainDuration = 8
    end
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Akala Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Akala Ocean Breeze boosts itself!",battler.pbThis))
    battler.increaseSpStacks(1)
    battler.increasePhStacks(1)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnZoneChange.add(:AKALAOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.zone == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Akala Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Akala Ocean Breeze boosts itself!",battler.pbThis))
    battler.increaseSpStacks(1)
    battler.increasePhStacks(1)
    battle.pbHideAbilitySplash(battler)
  }
)
      
BattleHandlers::AbilityOnWeatherChange.add(:AKALAOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.weather == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Akala Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Akala Ocean Breeze boosts itself!",battler.pbThis))
    battler.increaseSpStacks(1)
    battler.increasePhStacks(1)
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnTerrainChange.add(:ULAULAOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.terrain == :None
    if battle.field.terrain == :Grassy
      battle.pbDisplay(_INTL("The Grassy Terrain was extended!"))
      battle.field.terrainDuration = 8
    end
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Ula'ula Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Ula'ula Ocean Breeze boosts its allies!",battler.pbThis))
    battle.eachBattler do |b|
      next if b.opposes?(battler)
      b.increasePhStacks(1)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnZoneChange.add(:ULAULAOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.zone == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Ula'ula Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Ula'ula Ocean Breeze boosts its allies!",battler.pbThis))
    battle.eachBattler do |b|
      next if b.opposes?(battler)
      b.increasePhStacks(1)
    end
    battle.pbHideAbilitySplash(battler)
  }
)
      
BattleHandlers::AbilityOnWeatherChange.add(:ULAULAOCEANBREEZE,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.weather == :None
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Ula'ula Ocean Breeze"))
    battle.pbDisplay(_INTL("{1}'s Ula'ula Ocean Breeze boosts its allies!",battler.pbThis))
    battle.eachBattler do |b|
      next if b.opposes?(battler)
      b.increasePhStacks(1)
    end
    battle.pbHideAbilitySplash(battler)
  }
)

BattleHandlers::AbilityOnWeatherChange.add(:SANDALERT,
  proc { |ability, battler, battle, ability_changed|
    next if battle.field.weather != :Sandstorm
    battle.field.weatherDuration = 8
    battle.pbDisplay(_INTL("The sandstorm's duration was extended!")) 
  }
)

#===============================================================================
# TargetAfterMoveUse Passive handlers
#===============================================================================
BattleHandlers::TargetAbilityAfterMoveUse.add(:SPIKEMUTHGRIT,
  proc { |ability,target,user,move,switched,battle|
    next if !move.damagingMove?
    next if target.damageState.initialHP<target.totalhp/2 || target.hp>=target.totalhp/2
    next if !target.pbCanRaiseStatStage?(:SPECIAL_ATTACK,target)
    target.pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,target)
    next if target.fainted?
    battle.pbShowAbilitySplash(target,false,true,_INTL("Spikemuth Grit"))
    target.pbRecoverHP(target.totalhp*0.4)
    target.increaseSpStacks(3)
    battle.pbHideAbilitySplash(target)
  }
)

#===============================================================================
# OnTargetStatLoss Passive handlers
#===============================================================================
BattleHandlers::AbilityOnTargetStatLoss.add(:POSTWICKPERSEVERENCE,
  proc { |ability,battler,stat,stage,target,battle|
    next if (target && !target.opposes?(battler)) || stat != :DEFENSE
    battle.pbShowAbilitySplash(battler,false,true,_INTL("Postwick Perseverence"))
    target.pbLowerStatStageByAbility(:SPECIAL_DEFENSE,stage,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# Sync Challenge Passive handlers
#===============================================================================
# SS Brock (has Aggravation too - coded elsewhere)
BattleHandlers::StatLossImmunityAbility.copy(:SANDFORTRESS,:BROCKSGRIT)

# SS Misty
BattleHandlers::UserAbilityEndOfMove.copy(:SHIFTIERSTRIKER,:SSMISTY)
BattleHandlers::AbilityOnSwitchIn.copy(:HEALTHYHEALING,:SSMISTY)

# SS Erika
BattleHandlers::UserAbilityEndOfMove.copy(:HEALINGSUN,:SSERIKA)
BattleHandlers::StatusImmunityAbility.copy(:LEAFGUARD,:SSERIKA)

# SS Red (can skip recharge turns too)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:SSRED) # Piercing Gaze

# SST Red
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:SSTRED)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:SSTRED)
BattleHandlers::UserAbilityEndOfMove.copy(:SHOCKRECOVERY,:SSTRED)

# SS Blue
BattleHandlers::TargetAbilityOnHit.copy(:TEAMSHOUT,:SSBLUE)
BattleHandlers::UserAbilityEndOfMove.copy(:FORCEFIELD,:SSBLUE)

# SS Leaf
BattleHandlers::UserAbilityOnHit.add(:SSLEAF,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerUserAbilityOnHit(:VENOMOUS,user,target,move,battle)
    BattleHandlers.triggerUserAbilityOnHit(:SUNDERING,user,target,move,battle)
  }
)

# SS Giovanni
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:SSGIOVANNI)
BattleHandlers::MoveBaseTypeModifierAbility.copy(:EARTHEN,:SSGIOVANNI)
BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:SSGIOVANNI)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:SSGIOVANNI)

# SS Morty
BattleHandlers::UserAbilityEndOfMove.add(:SSMORTY,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:AFFLICTERSADVANTAGE,user,target,move,battle)
    BattleHandlers.triggerUserAbilityEndOfMove(:SUNBATHE,user,target,move,battle)
  }
)

# SS Ethan (also has extend range)
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:SSETHAN)
BattleHandlers::UserAbilityEndOfMove.copy(:MPREGAIN,:SSETHAN)

# SS Lyra
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:SSLYRA)
BattleHandlers::UserAbilityOnHit.add(:SSLYRA,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerUserAbilityOnHit(:HASSLINGHIT,user,target,move,battle)
    BattleHandlers.triggerUserAbilityOnHit(:RUTHLESS,user,target,move,battle)
  }
)

# SS Kris
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:SSKRIS)
BattleHandlers::UserAbilityEndOfMove.add(:SSKRIS,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:MINDBRACINGAFFLICTION,user,target,move,battle)
    BattleHandlers.triggerUserAbilityEndOfMove(:REFRESHINGRAIN,user,target,move,battle)
  }
)

# SS Silver
BattleHandlers::UserAbilityOnHit.add(:SSSILVER,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerUserAbilityOnHit(:EVASIVESTRIKE,user,target,move,battle)
    BattleHandlers.triggerUserAbilityOnHit(:TRIPPINGSTRIKE,user,target,move,battle)
  }
)

# SS Brendan (double stat drops and increase likelihood too)
BattleHandlers::AbilityOnSwitchIn.copy(:SMARTSTART,:SSBRENDAN)

# SS May
BattleHandlers::AbilityOnSwitchIn.copy(:DEBUTDASH,:SSMAY)
BattleHandlers::UserAbilityOnHit.copy(:DEFENSEDESTROYER,:SSMAY)

# SS Wally
BattleHandlers::AbilityOnSwitchIn.copy(:DEBUTDASH,:SSWALLY)
BattleHandlers::UserAbilityOnHit.copy(:GOBSMACK,:SSWALLY)

# SS Steven (4 passives - 1 for each form + initially has Pinpoint Entry)
# Passive 1 has no code here as it's Downside Up + Aggravation
BattleHandlers::UserAbilityEndOfMove.copy(:POWERCOMBO,:SSSTEVEN2)
BattleHandlers::UserAbilityEndOfMove.copy(:MINDBRACINGINFLICTION,:SSSTEVEN3)
BattleHandlers::UserAbilityEndOfMove.copy(:CATALYTICINFLICTION,:SSSTEVEN4)

# SS Cyrus
BattleHandlers::DamageCalcUserAbility.copy(:GOODNIGHTMARE,:SSCYRUS)
BattleHandlers::UserAbilityEndOfMove.copy(:BADBREAK,:SSCYRUS)

# SS Cynthia
# Has Unhindered - bypass damage reduction effects

# SSR Cynthia
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:SSCYNTHIA2)
BattleHandlers::UserAbilityOnHit.copy(:SUNDERING,:SSCYNTHIA2)
BattleHandlers::UserAbilityEndOfMove.copy(:HAUNTEDHEALING,:SSCYNTHIA2)

# SSA Cynthia
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:SSCYNTHIA3)
BattleHandlers::AbilityOnSwitchIn.copy(:PASSIONAURA,:SSCYNTHIA3)
BattleHandlers::UserAbilityEndOfMove.copy(:BRAWLINGRESTORATION,:SSCYNTHIA3)

# SS Dawn
BattleHandlers::DamageCalcUserAbility.copy(:FORTIFY,:SSDAWN)
BattleHandlers::UserAbilityEndOfMove.copy(:BRAINSTORM,:SSDAWN)

# SS Elesa
BattleHandlers::TargetAbilityOnHit.copy(:LOOKALIVE2,:SSELESA)
BattleHandlers::StatLossImmunityAbility.copy(:FASTRUNNER,:SSELESA)

# SS Grimsley (double chance)
BattleHandlers::DamageCalcUserAbility.copy(:POWERRESERVES,:SSGRIMSLEY)

# SS Hilbert (most of his gimmicks are tied to Techno Blast)
BattleHandlers::UserAbilityOnHit.copy(:SUPERSLOWERINGHIT,:SSHILBERT)

# SS Hilda (has Downside Up too)
BattleHandlers::AbilityOnSwitchIn.copy(:FIERCEENTRY2,:SSHILDA)

# SS N (has Piercing Blows + Hostile Env. so no code here)
# Ready for Anything is hardcoded into Freeze Shock

# SS Serena
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:SSSERENA)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:SSSERENA)
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:SSSERENA)

# SS Korrina
BattleHandlers::UserAbilityEndOfMove.copy(:FORTUITOUSX3,:SSKORRINA)

# SS Diantha
BattleHandlers::UserAbilityEndOfMove.copy(:HONINGHIT,:SSDIANTHA)
BattleHandlers::AbilityOnSwitchIn.copy(:TRIPPINGWIRE,:SSDIANTHA)

# SS Lysandre
# Only has Scorching Touch

# SS Lusamine (has Extend Range + ignore recharge as well)
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:SSLUSAMINE)

# SS Hau (Effectively just Melemele Ocean Breeze so no need to copy)

# SS Lana (Effectively just Akala Ocean Breeze)

# SS Acerola (Effectively just Ula'ula Ocean Breeze)

# SS Mina (Keeping hers as a regular ability because it makes sense to do so)

# SS Gladion
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:SSGLADION)
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:SSGLADION)
BattleHandlers::UserAbilityOnHit.copy(:SATISFIEDSNARL,:SSGLADION)

# SS Leon (Also skips recharge)
BattleHandlers::UserAbilityOnHit.copy(:LUCKYSEVEN,:SSLEON)

# SS Piers (also ignore Enduring effects)
BattleHandlers::AbilityOnSwitchIn.copy(:LOWKEYMELANCHOLY,:SSPIERS)

# SS Roxie (stat drop code above)
BattleHandlers::AbilityOnSwitchIn.copy(:AMPEDANDVIBED,:SSROXIE)

# SS Ingo
BattleHandlers::UserAbilityEndOfMove.add(:SSINGO,
  proc { |ability,user,targets,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:SEEKINGHIT,user,targets,move,battle)
    BattleHandlers.triggerUserAbilityEndOfMove(:BRAINGAIN,user,targets,move,battle)
  }
)

# SS Emmet
BattleHandlers::UserAbilityEndOfMove.copy(:HONINGHIT,:SSEMMET)
BattleHandlers::UserAbilityOnHit.copy(:ATTACKTRAP,:SSEMMET)

# SSU Giovanni
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:SSGIOVANNI2)
BattleHandlers::UserAbilityEndOfMove.copy(:BATTLEARMOR,:SSGIOVANNI2)

# Dojo Gloria
BattleHandlers::UserAbilityOnHit.add(:DOJOGLORIA,
  proc { |ability,user,target,move,battle|
    BattleHandlers.triggerUserAbilityOnHit(:PUNISHINGSTRIKE,user,target,move,battle)
    BattleHandlers.triggerUserAbilityOnHit(:TRIPPINGSTRIKE,user,target,move,battle)
  }
)

# Anni Lillie (also has Quick Tempo)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:ANNILILLIE)
BattleHandlers::DamageCalcUserAbility.copy(:HEALTHYPOWERUP,:ANNILILLIE)

# Anni N (also has Extend Range and Piercing Blows)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:ANNIN)
BattleHandlers::UserAbilityEndOfMove.add(:ANNIN,
  proc { |ability,user,targets,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:PEPRALLY,user,targets,move,battle)
    BattleHandlers.triggerUserAbilityEndOfMove(:MINDGAMES,user,targets,move,battle)
  }
)

# Anni Steven (also has Downside Up)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:ANNISTEVEN)
BattleHandlers::UserAbilityEndOfMove.copy(:FLEETERFEET,:ANNISTEVEN)

# Anni May (double stat drops and increase likelihood)

# Anni Skyla (increase likelihood of added effects)
BattleHandlers::UserAbilityOnHit.copy(:GOBSMACK,:ANNISKYLA)

# Anni Raihan
BattleHandlers::UserAbilityOnHit.copy(:DISARM,:ANNIRAIHAN)
BattleHandlers::UserAbilityEndOfMove.copy(:STRENGTHENINGSTATUS,:ANNIRAIHAN)

# NC Serena
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:NCSERENAW,:NCSERENAD)
# Water also has Skill Link
BattleHandlers::UserAbilityOnHit.copy(:UNFORTUNATESTRIKE,:NCSERENAW)
# Dark also has Stench-like effect
BattleHandlers::UserAbilityOnHit.copy(:DISCOMBOBULATE,:NCSERENAD)

# NC Calem
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCCALEMW,:NCCALEMD)
BattleHandlers::UserAbilityEndOfMove.copy(:REFRESHINGRAIN,:NCCALEMW)
BattleHandlers::StatusImmunityAbility.copy(:STATUSIMMUNITY,:NCCALEMW)
BattleHandlers::StatLossImmunityAbility.copy(:CLEARBODY,:NCCALEMD)
BattleHandlers::UserAbilityEndOfMove.copy(:UMBRALRESTORATION,:NCCALEMD)

# NC Marnie (also has Sharp Entry 3)
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:NCMARNIE)
BattleHandlers::DamageCalcUserAbility.copy(:MINDOVERMATTER,:NCMARNIE)
#BattleHandlers::TargetAbilityAfterMoveUse.copy(:SPIKEMUTHGRIT,:NCMARNIE)

# NC Hop (also has Fierce Entry 2)
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCHOP)
BattleHandlers::AbilityOnTargetStatLoss.copy(:POSTWICKPERSEVERENCE,:NCHOP)

# NC Bede (also has Debut Dash)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:NCBEDE)
BattleHandlers::CriticalCalcTargetAbility.copy(:BATTLEARMOR,:NCBEDE)

# NC Red
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:NCRED)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:NCRED)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCRED)
BattleHandlers::UserAbilityOnHit.copy(:SHIMMERINGWHITESNOW,:NCRED)
BattleHandlers::UserAbilityEndOfMove.copy(:JOURNEYFROMPALLET,:NCRED)

# NC Leaf
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCLEAF)
BattleHandlers::UserAbilityEndOfMove.add(:NCLEAF,
  proc { |ability,user,targets,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:LOVEOFPALLET,user,targets,move,battle)
    BattleHandlers.triggerUserAbilityEndOfMove(:ILLUMINATINGWHITEBLAZE,user,targets,move,battle)
  }
)

# NC Blue (also has Stench-like effect)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:NCBLUE)
BattleHandlers::UserAbilityOnHit.copy(:ROARINGWHITELIGHTNING,:NCBLUE)
BattleHandlers::UserAbilityEndOfMove.copy(:PRIDEOFPALLET,:NCBLUE)

# NC Nate
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCNATE)
BattleHandlers::UserAbilityEndOfMove.copy(:ATTACKBOOSTERMAX,:NCNATE)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCNATE)

# NC Rosa (Move type change code above)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:NCROSA)
BattleHandlers::DamageCalcUserAbility.copy(:AERILATE,:NCROSA)
BattleHandlers::UserAbilityOnHit.copy(:ENTRANCINGMELODY,:NCROSA)
BattleHandlers::UserAbilityEndOfMove.copy(:ARIAPERFORMANCE,:NCROSA)

# NC Silver
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCSILVER)
BattleHandlers::AbilityOnWeatherChange.copy(:SANDALERT,:NCSILVER)
BattleHandlers::DamageCalcUserAbility.copy(:SANDFORCE,:NCSILVER)
BattleHandlers::UserAbilityEndOfMove.copy(:SANDYBRAWNGAIN,:NCSILVER)

# NC Cheren
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:NCCHEREN)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:NCCHEREN)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCCHEREN)
BattleHandlers::UserAbilityEndOfMove.copy(:POWERCOMBO,:NCCHEREN)

# NC Bianca (Also has piercing blows)
BattleHandlers::AbilityOnSwitchIn.copy(:FLAGBEARER,:NCBIANCA)
BattleHandlers::UserAbilityEndOfMove.add(:NCBIANCA,
  proc { |ability,user,targets,move,battle|
    BattleHandlers.triggerUserAbilityEndOfMove(:PEPRALLY,user,targets,move,battle)
    BattleHandlers.triggerUserAbilityEndOfMove(:EVASIVEMANEUVERS,user,targets,move,battle)
  }
)

# NC May (also has Grand Entry 2)
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:NCMAY)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:NCMAY)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCMAY)
BattleHandlers::DamageCalcUserAbility.copy(:RAGINGRAIN,:NCMAY)

# NC Brendan (also has Fierce Entry 2)
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCBRENDAN)
BattleHandlers::AccuracyCalcUserAbility.copy(:NOGUARD,:NCBRENDAN)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCBRENDAN)
BattleHandlers::DamageCalcUserAbility.copy(:SOLARPOWER,:NCBRENDAN)

# NC Elio (also has Fierce Entry 2)
BattleHandlers::AbilityOnSwitchIn.copy(:PRIDE,:NCELIO)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCELIO)
BattleHandlers::TargetAbilityOnHit.copy(:AUTOHEAL,:NCELIO)

# NC Selene (also has Grand Entry 2)
BattleHandlers::AbilityOnSwitchIn.copy(:SPIRIT,:NCSELENE)
BattleHandlers::CriticalCalcUserAbility.copy(:CLUTCHCRITICAL,:NCSELENE)
BattleHandlers::TargetAbilityOnHit.copy(:AUTOHEAL,:NCSELENE)

