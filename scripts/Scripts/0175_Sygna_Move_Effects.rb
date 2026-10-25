#===============================================================================
############################## CUSTOM MOVES ####################################
#===============================================================================
############################ SS TRAINER MOVES ##################################
#===============================================================================
# Increases user's Def by 1 stage, then guarantees sure hit and crit hit on next
# attack. (SS Brock)
#===============================================================================
class PokeBattle_Move_ST01 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,1]
  end
  
  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::LaserFocus] = 2
    user.effects[PBEffects::SureHit]    = 2
    @battle.pbDisplay(_INTL("{1} concentrated very intensely!",user.pbThis))
  end
end
  


#===============================================================================
# Increases user's Def and team's Sp. Def by 2 stages. (SS Misty)
#===============================================================================
class PokeBattle_Move_ST02 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_DEFENSE,2]
  end

  def pbEffectGeneral(user)
    user.pbRaiseStatStage(:DEFENSE,2,user) if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
    super
  end
end



#===============================================================================
# Increases user's Atk and Crit Rate by 2 and 1 stages respectively. Doubles
# when in Sun and applies Ingrain to the user. (SS Erika)
#===============================================================================
class PokeBattle_Move_ST03 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2]
    @crit = 1
  end
  
  def pbEffectGeneral(user)
    super
    if @increment == 2 && !user.effects[PBEffects::Ingrain]
      user.effects[PBEffects::Ingrain] = true
      @battle.pbDisplay(_INTL("{1} planted its roots!",user.pbThis))
    end
  end

  def pbOnStartUse(user,targets)
    @increment = [:Sun, :HarshSun].include?(@battle.pbWeather) ? 2 : 1
    @statUp[1] = 2 * @increment
    @crit = @increment
  end
end



#===============================================================================
# Increases user's Atk, Sp. Atk and Speed by 3 stages, user's Crit Rate by 2
# stages and lowers user's Def. and Sp. Def by 1 stage. (SS Red)
#===============================================================================
class PokeBattle_Move_ST04 < PokeBattle_MultiStatUpDownMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,3,:SPECIAL_ATTACK,3,:SPEED,3]
    @statDown = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
    @crit = 2
  end
end


  
#===============================================================================
# Maxes user's Atk and applies Grad. Healing to all allies. (SS TB Red)
#===============================================================================
class PokeBattle_Move_ST05 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.pbRaiseStatStage(:ATTACK,6,user) if user.pbCanRaiseStatStage?(:ATTACK,user,self)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      next if b.effects[PBEffects::GradualHealing]
      b.effects[PBEffects::GradualHealing] = true
      @battle.pbDisplay(_INTL("{1} gained a restorative aura!",user.pbThis))
    end
  end
end


 
#===============================================================================
# Raises all allies Def, Sp. Def, Speed and Crit Rate by 1 stage and sets up
# Tailwind. (SS Morty)
#===============================================================================
class PokeBattle_Move_ST06 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,1,:SPECIAL_DEFENSE,1,:SPEED,1]
    @crit = 1
    @tailwind = true
  end
end



#===============================================================================
# Raises user's Accuracy by 1 stage and SMUP by 3 stacks. If its next move is an
# attack, it will Crit. (SS Ethan)
#===============================================================================
class PokeBattle_Move_ST07 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ACCURACY,1]
    @spStacks = 3
  end
  
  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!",user.pbThis))
  end
end



#===============================================================================
# Raises user or ally's Atk and Sp. Atk by 2 stages and applies gradual healing
# to that Pokémon. (SS Lyra)
#===============================================================================
class PokeBattle_Move_ST08 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.pbRaiseStatStage(:ATTACK,2,user)
    target.pbRaiseStatStage(:SPECIAL_ATTACK,2,user)
    target.effects[PBEffects::GradualHealing] = true
    @battle.pbDisplay(_INTL("{1} gained a restorative aura!",target.pbThis))
  end
end



#===============================================================================
# Raise all allies Sp. Atk by 2 stages and Crit rate by 1 stage, also raises
# allies' SMUP by 1 stage when raining. Sets up Tailwind. (SS Kris)
#===============================================================================
class PokeBattle_Move_ST09 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,2]
    @crit = 1
    @tailwind = true
  end
  
  def pbOnStartUse(user,targets)
    @spStacks = [:Rain,:HeavyRain].include?(@battle.pbWeather) ? 1 : 0 
  end
end



#===============================================================================
# Raises user's Attack and Speed by 3 stages and sets up Tailwind. (SS Silver)
#===============================================================================
class PokeBattle_Move_ST10 < PokeBattle_MultiStatUpMove  
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,3,:SPEED,3]
    @tailwind = true
  end
end



#===============================================================================
# Raises allies' Sp. Atk + Sp. Def by 4 stages and crit rate by 1 stage.
# (SS Brendan)
#===============================================================================
class PokeBattle_Move_ST11 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,4,:SPECIAL_DEFENSE,4,:SPEED,1]
    @crit = 1
  end
end


  
#===============================================================================
# Increases the user's Attack by 4 stages and Accuracy by 1 stage. Sets Tailwind
# and Protects the user from damage for 1 turn. (SS May)
#===============================================================================
class PokeBattle_Move_ST12 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4,:ACCURACY,1]
    @tailwind = true
  end

  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::Protect] = true
    user.effects[PBEffects::ProtectRate] = 1
    @battle.pbDisplay(_INTL("{1} protected itself!", user.pbThis))
  end
end
    


#===============================================================================
# Sets Psychic Terrain, then sharply raises the user's Def., Sp. Atk., Sp. Def.
# and Speed and changes its moves. (SS Steven's Try This!)
#===============================================================================
class PokeBattle_Move_ST13 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,2,:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,:SPEED,2]
  end
  
  def pbMoveFailed?(user,targets)
    if !user.isSpecies?(:DEOXYS) && user.effects[PBEffects::TransformSpecies] != :DEOXYS
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Psychic)
    super
    attackMoves = [Pokemon::Move.new(:PSYCHOBOOST),Pokemon::Move.new(:RECOVER),Pokemon::Move.new(:ZENHEADBUTT),Pokemon::Move.new(:PROTECT)]
    for i in 0...4
      user.pokemon.moves[i] = attackMoves[i]
      user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
      @battle.pbDisplay(_INTL("{1} now knows {2}!",user.pbThis,attackMoves[i].name))
    end
    user.passive = :SSSTEVEN
  end
end

    

#===============================================================================
# Maxes user's Sp. Atk and Crit Rate, changes into Attack Forme and changes its
# moves. (Attack!)
#===============================================================================
class PokeBattle_Move_ST14 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
    @crit = 3
  end
  
  def pbMoveFailed?(user,targets)
    if !user.isSpecies?(:DEOXYS) && user.effects[PBEffects::TransformSpecies] != :DEOXYS
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    super
    user.pbChangeForm(1,_INTL("{1} became more aggresive!",user.pbThis))
    attackMoves = [Pokemon::Move.new(:PSYCHOBOOST),Pokemon::Move.new(:PROTECT),Pokemon::Move.new(:ZENHEADBUTT),Pokemon::Move.new(:RECOVER)]
    for i in 0...4
      user.pokemon.moves[i] = attackMoves[i]
      user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
      @battle.pbDisplay(_INTL("{1} now knows {2}!",user.pbThis,attackMoves[i].name))
    end
    user.passive = :SSSTEVEN2
  end
end


    
#===============================================================================
# Maxes user's Speed, drastically raises its Evasion, changes into Speed Forme
# and changes its moves. (Faster!)
#===============================================================================
class PokeBattle_Move_ST15 < PokeBattle_Move
  def initialize(battle,move)
    super
    @statUp = [:SPEED,6,:EVASION,3]
  end
  
  def pbMoveFailed?(user,targets)
    if !user.isSpecies?(:DEOXYS) && user.effects[PBEffects::TransformSpecies] != :DEOXYS
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    super
    user.pbChangeForm(3,_INTL("{1} became more nimble!",user.pbThis))
    attackMoves = [Pokemon::Move.new(:PSYCHOBOOST),Pokemon::Move.new(:PROTECT),Pokemon::Move.new(:ZENHEADBUTT),Pokemon::Move.new(:DOUBLETEAM)]
    for i in 0...4
      user.pokemon.moves[i] = attackMoves[i]
      user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
      @battle.pbDisplay(_INTL("{1} now knows {2}!",user.pbThis,attackMoves[i].name))
    end
    user.passive = :SSSTEVEN3
  end
end


    
#===============================================================================
# Drasically raises all allies' Atk. and Sp. Atk, changes into Defense Forme
# and protects itself against damage for the rest of the turn. (Defend!)
#===============================================================================
class PokeBattle_Move_ST16 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4,:SPECIAL_ATTACK,4]
  end
  
  def pbMoveFailed?(user,targets)
    if !user.isSpecies?(:DEOXYS) && user.effects[PBEffects::TransformSpecies] != :DARKRAI
      @battle.pbDisplay(_INTL("But {1} can't use the move!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    super
    user.pbChangeForm(2,_INTL("{1} became bulkier!",user.pbThis))
    attackMoves = [Pokemon::Move.new(:PSYCHOBOOST),Pokemon::Move.new(:PROTECT),Pokemon::Move.new(:ZENHEADBUTT),Pokemon::Move.new(:IRONDEFENSE)]
    for i in 0...4
      user.pokemon.moves[i] = attackMoves[i]
      user.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
      @battle.pbDisplay(_INTL("{1} now knows {2}!",user.pbThis,attackMoves[i].name))
    end
    user.effects[PBEffects::Protect] = true
    user.effects[PBEffects::ProtectRate] = 1
    @battle.pbDisplay(_INTL("{1} protected itself!",user.pbThis))
    user.passive = :SSSTEVEN4
  end
end



#===============================================================================
# Raises user's Sp. Atk by 2 stages and Sp. Def and Crit Rate by 1 stage.
# (SS Wally)
#===============================================================================
class PokeBattle_Move_ST17 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,1]
    @crit = 1
  end
end



#===============================================================================
# Raises user's Sp. Atk by 2 stages and Accuracy and Crit Rate by 1 stage.
# (SS Cyrus)
#===============================================================================
class PokeBattle_Move_ST18 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,2,:ACCURACY,1]
    @crit = 1
  end
end



#===============================================================================
# Raises user's Crit Rate and SMUP based on remaining HP. (SS Cynthia)
#===============================================================================
class PokeBattle_Move_ST19 < PokeBattle_Move
  def pbEffectGeneral(user)
    percent = (user.hp/user.totalhp)*100
    if percent <= 50
      user.raiseCritRate(3)
      user.increaseSpStacks(6)
    elsif percent <= 75
      user.raiseCritRate(2)
      user.increaseSpStacks(4)
    else
      user.raiseCritRate(1)
      user.increaseSpStacks(2)
    end
  end
end



#===============================================================================
# Raises user's Atk and Sp. Atk by 4 stages and Crit Rate by 3 stages. Lowers
# user's Def and Sp. Def by 1 stage. (SSR Cynthia)
#===============================================================================
class PokeBattle_Move_ST20 < PokeBattle_MultiStatUpDownMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4,:SPECIAL_ATTACK,4]
    @statDown = [:DEFENSE,1,:SPECIAL_DEFENSE,1]
    @crit = 3
  end
end



#===============================================================================
# Increases all allies' Def and Sp. Def by 4 or 6 stages. (SSA Cynthia)
#===============================================================================
class PokeBattle_Move_ST21 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,4,:SPECIAL_DEFENSE,4]
  end

  def pbOnStartUse(user,targets)
    increment = (@battle.field.zone==:Fighting) ? 6 : 4
    @statUp[1] = @statUp[3] = increment
  end
end



#===============================================================================
# Increases all allies' Def., Sp. Def. and Crit Rate by 2 stages. (SS Dawn)
#===============================================================================
class PokeBattle_Move_ST22 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,2,:SPECIAL_DEFENSE,2]
    @crit = 2
  end
  
  def pbEffectGeneral(user)
    super
    user.pbReduceHP(0.3*user.totalhp)
  end
end



#===============================================================================
# Increases an ally's Crit Rate and Accuracy by 2 stages, then raises all
# allies' Sp. Atk by 2 stages. (SS Elesa)
#===============================================================================
class PokeBattle_Move_ST23 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,2]
  end
  
  def pbEffectAgainstTarget(user,target)
    target.pbRaiseStatStage(:ACCURACY,2,user)
    target.raiseCritRate(2)
  end
end


#===============================================================================
# At the cost of 90% of the user's current HP, maxes out the user's evasion,
# attack and Crit Rate and cures the user's status condition. (SS Grimsley)
#===============================================================================
class PokeBattle_Move_ST24 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6,:EVASION,6]
    @crit = 3
  end
  
  def pbEffectGeneral(user)
    user.pbReduceHP(0.9*user.hp)
    user.pbCureStatus if [:BURN, :POISON, :PARALYSIS, :SLEEP, :FROZEN].include?(user.status)
    super
  end
end



#===============================================================================
# Increase Sp. Atk. based on how much Atk. is currently raised, max out 
# Crit Rate and raise team's Acc. by 1 stage. (SS Hilda)
#===============================================================================
class PokeBattle_Move_ST25 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ACCURACY,1] # Sp. Attack is dependant on Atk
    @crit = 3
  end
  
  def pbEffectGeneral(user)
    if user.stages[:ATTACK] > 0 && user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
      user.pbRaiseStatStage(:SPECIAL_ATTACK,user.stages[:ATTACK],user)
    end
    super
    user.eachAlly do |b|
      next if !b.pbCanRaiseStatStage?(:ACCURACY,user,self)
      b.pbRaiseStatStageByAbility(:ACCURACY,1,user,false)
    end
  end
end



#===============================================================================
# Raises Sp. Atk. by 3 stages, then raises Crit Rate and SMUP by 2 stages.
# (SS Hilbert)
#===============================================================================
class PokeBattle_Move_ST26 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,3]
    @crit = 2
    @spStacks = 2
  end
end



#===============================================================================
# Raises attack by 4 stages and maxes Crit Rate. (SS N)
#===============================================================================
class PokeBattle_Move_ST27 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4]
    @crit = 3
  end
end

    

#===============================================================================
# Raise the user's Sp. Atk by 4 stages, max out its Crit Rate and set up
# Tailwind. (SS Roxie)
#===============================================================================
class PokeBattle_Move_ST28 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,4]
    @crit = 3
    @tailwind = true
  end
end



#===============================================================================
# Maxes the user's Atk. and Sp. Atk while applying Gradual Healing. (SS Serena)
#===============================================================================
class PokeBattle_Move_ST29 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6,:SPECIAL_ATTACK,6]
  end
  
  def pbEffectGeneral(user)
    super
    return if user.effects[PBEffects::GradualHealing]
    user.effects[PBEffects::GradualHealing] = true
    @battle.pbDisplay(_INTL("{1} gained a restorative aura!",user.pbThis))
  end
end



#===============================================================================
# Raises user's Atk. by 4 stages, then raises user's Speed and Evasion by 3
# stages. (SS Korrina)
#===============================================================================
class PokeBattle_Move_ST30 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4,:SPEED,3,:EVASION,3]
  end
end



#===============================================================================
# Raises user's Sp. Def by how much the user's Def. has been raised, then
# applies Gradual Healing and increases PMUP by 2 stacks. (SS Diantha)
#===============================================================================
class PokeBattle_Move_ST31 < PokeBattle_Move
  def pbEffectGeneral(user)
    if user.stages[:DEFENSE] > 0 && user.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbRaiseStatStage(:SPECIAL_DEFENSE,user.stages[:DEFENSE],user)
    end
    if !user.effects[PBEffects::GradualHealing]
      user.effects[PBEffects::GradualHealing] = true
      @battle.pbDisplay(_INTL("{1} gained a restorative aura!",user.pbThis))
    end
    user.increasePhStacks(2)
  end
end
  


#===============================================================================
# Raises user's Sp. Atk. by 4 stages, Accuracy by 1 stage and maxes out Crit
# Rate. (SS Lysandre)
#===============================================================================
class PokeBattle_Move_ST32 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,4,:ACCURACY,1]
    @crit = 3
  end
end



#===============================================================================
# Maxes out user's Sp. Atk and lowers speed by 1 stage. (SS Lusamine)
#===============================================================================
class PokeBattle_Move_ST33 < PokeBattle_MultiStatUpDownMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
    @statDown = [:SPEED,1]
  end
end



#===============================================================================
# Increases the user's Sp. Attack by 4 stages and Crit by 2 stages. (SS Hau)
#===============================================================================
class PokeBattle_Move_ST34 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,4]
    @crit = 2
  end
end



#===============================================================================
# Maxes the user's Atk. and Sp. Atk while increasing PMUP and SMUP by 1 stack.
# (SS Lana)
#===============================================================================
class PokeBattle_Move_ST35 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6,:SPECIAL_ATTACK,6]
    @phStacks = 1
    @spStacks = 1
  end
end



#===============================================================================
# Raises all allies' Def. by 2 stages and Crit Rate by 3 stages. Additionally
# raises all allies' Speed by 2 stages when Sunny. (SS Acerola)
#===============================================================================
class PokeBattle_Move_ST36 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,2]
    @crit = 3
  end
  
  def pbEffectGeneral(user)
    @statUp = ([:HarshSun, :Sun].include?(@battle.field.weather)) ? [:DEFENSE,2,:SPEED,2] : [:DEFENSE,2]
    super
  end
end



#===============================================================================
# Applies Lucky Chant to user's field of play, gives all allies gradual healing
# and increases all allies' Sp. Atk by 4 stages or maxes out when Raining.
# (SS Mina)
#===============================================================================
class PokeBattle_Move_ST37 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,4]
  end
  
  def pbEffectGeneral(user)
    if !(user.pbOwnSide.effects[PBEffects::LuckyChant] > 0)
      user.pbOwnSide.effects[PBEffects::LuckyChant] = 5
      @battle.pbDisplay(_INTL("The Lucky Chant shielded {1} from critical hits!",user.pbTeam(true)))
    end
    @statUp[1] = ([:HeavyRain, :Rain].include?(@battle.field.weather)) ? 6 : 4
    super
    @battle.eachBattler do |b|
      next if b.opposes?(user) || b.effects[PBEffects::GradualHealing]
      b.effects[PBEffects::GradualHealing] = true
      @battle.pbDisplay(_INTL("{1} gained a restorative aura!",b.pbThis))
    end
  end
end



#===============================================================================
# Max out user's Sp. Atk, Crit Rate and increase SMUP by 1 stack. (SS Gladion)
#===============================================================================
class PokeBattle_Move_ST38 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
    @crit = 3
    @spStacks = 1
  end
end




#===============================================================================
# Raises the user's Sp. Atk by 3 stages and Crit Rate by 2 stages. Lowers the
# user's Sp. Def. by 1 stage. (SS Leon)
#===============================================================================
class PokeBattle_Move_ST39 < PokeBattle_MultiStatUpDownMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,3]
    @statDown = [:SPECIAL_DEFENSE,1]
    @crit = 2
  end
end



#===============================================================================
# Set Poison Zone, then raise the user's Sp. Atk and Crit Rate by 2 stages.
# (SS Piers)
#===============================================================================
class PokeBattle_Move_ST40 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,2]
    @crit = 2
  end
  
  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Poison)
    super
  end
end

  

#===============================================================================
# Raises all allies' Speed by 4 stages and Evasion by 2 stages. (SS Ingo)
#===============================================================================
class PokeBattle_Move_ST41 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,4,:EVASION,2]
  end
end



#===============================================================================
# The target's attacks before the end of the next turn become critical hits
# and the target becomes immune to Ground attacks for 5 turns. (SS Emmet)
#===============================================================================
class PokeBattle_Move_ST42 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::LaserFocus] = 2
    @battle.pbDisplay(_INTL("{1} concentrated intensely!",target.pbThis))
    target.effects[PBEffects::MagnetRise] = 5
    @battle.pbDisplay(_INTL("{1} became immune to Ground type attacks for 5 turns!",target.pbThis))
  end
end



#===============================================================================
# Max out attack. (SS Giovanni)
#===============================================================================
class PokeBattle_Move_ST43 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6]
  end
end



#===============================================================================
# Raise all allies' Atk. and Sp. Atk by 2 stages and Crit Rate by 1 stage.
# User becomes center of attention. (SS Ultra Giovanni)
#===============================================================================
class PokeBattle_Move_ST44 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPECIAL_ATTACK,2]
    @crit = 1
  end
  
  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::FollowMe] = 1
    user.eachAlly do |b|
      next if b.effects[PBEffects::FollowMe] < user.effects[PBEffects::FollowMe]
      user.effects[PBEffects::FollowMe] = b.effects[PBEffects::FollowMe] + 1
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",user.pbThis))
  end
end



#===============================================================================
# Raise all allies' Def. by 2 stages and Crit Rate by 1 stage. Apply Tailwind
# to the user's side. (SS Blue)
#===============================================================================
class PokeBattle_Move_ST45 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,2]
    @crit = 1
    @tailwind = true
  end
end



#===============================================================================
# Heals side for 40% of its Max HP and apply Gradual Healing. (SS Leaf)
#===============================================================================
class PokeBattle_Move_ST46 < PokeBattle_Move
  def healingMove?;       return true; end
  def pbHealAmount(user); return 0.4*user.totalhp;    end
    
  def pbEffectPerTarget(target)
    target.pbRecoverHP(pbHealAmount(target))
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",target.pbThis))
    return if target.effects[PBEffects::GradualHealing]
    target.effects[PBEffects::GradualHealing] = true
    @battle.pbDisplay(_INTL("{1} gained a restorative aura!",target.pbThis))
  end

  def pbEffectGeneral(user)
    pbEffectPerTarget(user)
    user.eachAlly { |b| pbEffectPerTarget(b) }
  end
end



#===============================================================================
# Raise Atk by 3 stages. (Dojo Gloria)
#===============================================================================
class PokeBattle_Move_ST99 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,3]
  end
end
  


#===============================================================================
# Maxes out Sp. Atk and Crit Rate. (Anni Lillie 2024)
#===============================================================================
class PokeBattle_Move_AT01 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
    @crit = 3
  end
end
  


#===============================================================================
# Raises Sp. Atk by 3 stages and Accuracy by 1 stage. (Anni N)
#===============================================================================
class PokeBattle_Move_AT02 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,3,:ACCURACY,1]
  end
end
  


#===============================================================================
# Raises Atk by 2 stages and maxes out Crit Rate. (Anni Steven)
#===============================================================================
class PokeBattle_Move_AT03 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2]
    @crit = 3
  end
end



#===============================================================================
# Raises user's Def. and Sp. Def by 2 stages, maxes out Crit Rate and sets up
# Talwind on the user's side. (Anni May)
#===============================================================================
class PokeBattle_Move_AT04 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,2,:SPECIAL_DEFENSE,2]
    @crit = 3
    @tailwind = true
  end
end



#===============================================================================
# Raise user's Sp. Atk and Crit Rate by 1 stage, then raises all allies' Speed
# by 2 stages. (Anni Skyla)
#===============================================================================
class PokeBattle_Move_AT05 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,2]
  end
  
  def pbEffectGeneral(user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
    user.raiseCritRate(1)
    super
  end
end



#===============================================================================
# Raise user's Sp. Atk by 4 stages, Crit Rate by 2 stage, then raises all
# allies' PMUP and SMUP by 2 stages. (Anni Raihan)
#===============================================================================
class PokeBattle_Move_AT06 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,4]
    @crit = 2
  end
  
  def pbEffectGeneral(user)
    super
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.increasePhStacks(2)
      b.increaseSpStacks(2)
    end
  end
end



#===============================================================================
# Raises attack by 4 stages and Crit Rate by 2. (Anni Lillie 2025)
#===============================================================================
class PokeBattle_Move_AT07 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4]
    @crit = 2
  end
end



#===============================================================================
# Raise user's Atk. by 2 stages, Sp. Atk by 4 stages and maxes out the user's
# Crit Rate. (NC Serena)
#===============================================================================
class PokeBattle_Move_NT01 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPECIAL_ATTACK,4]
    @crit = 3
  end
end



#===============================================================================
# Raise all allies' Atk. by 4 stages, Sp. Atk and Crit Rate by 2 stages and
# sets up Tailwind. (NC Calem)
#===============================================================================
class PokeBattle_Move_NT02 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4,:SPECIAL_ATTACK,2]
    @crit = 2
    @tailwind = true
  end
end



#===============================================================================
# Maxes out user's Sp. Atk, raises Spd. by 4 stages, Evasion by 2 stages and
# take 10% recoil damage. (NC Marnie)
#===============================================================================
class PokeBattle_Move_NT03 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6,:SPEED,4,:EVASION,2]
  end
  
  def pbEffectGeneral(user)
    super
    user.pbReduceHP(user.totalhp/10)
  end
end



#===============================================================================
# Sets up Fighting Zone, raises Spd. by 3 stages and lowers the user's Sp. Def.
# by 1 stage. (NC Hop)
#===============================================================================
class PokeBattle_Move_NT04 < PokeBattle_MultiStatUpDownMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,3]
    @statDown = [:SPECIAL_DEFENSE,1]
  end
  
  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Fighting)
    super
  end
end



#===============================================================================
# Raise all allies' Atk., Sp. Atk and Crit Rate by 2 stages and PMUP and SMUP
# stacks by 1. (NC Bede)
#===============================================================================
class PokeBattle_Move_NT05 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,2,:SPECIAL_ATTACK,2]
    @crit = 2
    @phStacks = 1
    @spStacks = 1
  end
end



#===============================================================================
# Maxes out user's Sp. Atk and raises SMUP stacks by 2. (NC Red)
#===============================================================================
class PokeBattle_Move_NT06 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
    @spStacks = 2
  end
end



#===============================================================================
# Maxes out Sp. Atk and Crit Rate and raises 2 SMUP stacks of all Pokémon on
# its side of the field. (NC Blue)
#===============================================================================
class PokeBattle_Move_NT07 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
    @crit = 3
    @spStacks = 2
  end
end



#===============================================================================
# Maxes out Atk., Sp. Atk. and Crit Rate. (NC Leaf)
#===============================================================================
class PokeBattle_Move_NT08 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6,:SPECIAL_ATTACK,6]
    @spStacks = 3
  end
end



#===============================================================================
# Return lowered stat stages back to normal, then raise user's speed by 3
# stages. (NC Nate)
#===============================================================================
class PokeBattle_Move_NT09 < PokeBattle_Move
  def pbEffectGeneral(user)
    if user.hasLoweredStatStages?
      user.pbResetLoweredStatStages
      @battle.pbDisplay(_INTL("{1}'s lowered stats returned to normal!", user.pbThis))
    end
    user.pbRaiseStatStage(:SPEED,3,user) if user.pbCanRaiseStatStage?(:SPEED,user,self)
  end
end


#===============================================================================
# Increase all allies' SMUP or PMUP stacks by 2 when in Aria and Pirouette forms
# respectively. (NC Rosa)
#===============================================================================
class PokeBattle_Move_NT10 < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.increaseSpStacks(2) if user.form == 0
      b.increasePhStacks(2) if user.form == 1
    end
  end
end



#===============================================================================
# Maxes out user's Atk and Crit Rate. Increase Acc. by 1 stage if in Sandstorm.
# (NC Silver)
#===============================================================================
class PokeBattle_Move_NT11 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6]
    @crit = 3
  end
  
  def pbEffectGeneral(user)
    @statUp = (@battle.field.weather == :Sandstorm) ? [:ATTACK,6,:ACCURACY,1] : [:ATTACK,6]
    super
  end
end



#===============================================================================
# Increase user's Atk and Sp. Atk by 4 stages as well as its PMUP and SMUP
# stacks by 2. (NC Cheren)
#===============================================================================
class PokeBattle_Move_NT12 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,4,:SPECIAL_ATTACK,4]
    @phStacks = 2
    @spStacks = 2
  end
end


# NC Bianca has the same Trainer Move as SS N (minus the PoMas shenanigans) so
# no need to create an extra class for hers


#===============================================================================
# Increase Sp. Atk. by 2 stages. Increase target's SMUP stacks by 2, then raise
# user's SMUP stacks by 2. (NC May)
#===============================================================================
class PokeBattle_Move_NT13 < PokeBattle_Move
  def pbEffectAgainstTarget(user, target)
    if user == target
      user.increaseSpStacks(4)
    else
      target.increaseSpStacks(2)
      user.increaseSpStacks(2)
    end
    return if !user.pbCanRaiseStatStage?(:SPECIAL_ATTACK, user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK, 2, user)
  end
end



#===============================================================================
# Increase Atk. by 2 stages. Increase target's PMUP stacks by 2, then raise
# user's PMUP stacks by 2. (NC Brendan)
#===============================================================================
class PokeBattle_Move_NT14 < PokeBattle_Move
  def pbEffectAgainstTarget(user, target)
    if user == target
      user.increasePhStacks(4)
    else
      target.increasePhStacks(2)
      user.increasePhStacks(2)
    end
    return if !user.pbCanRaiseStatStage?(:ATTACK, user)
    user.pbRaiseStatStage(:ATTACK, 2, user)
  end
end



#===============================================================================
# Set Steel Zone and increase PMUP stacks by 2. (NC Elio)
#===============================================================================
class PokeBattle_Move_NT15 < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Steel)
    user.increasePhStacks(2)
  end
end



#===============================================================================
# Set Ghost Zone and increase SMUP stacks by 2. (NC Selene)
#===============================================================================
class PokeBattle_Move_NT16 < PokeBattle_Move
  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Ghost)
    user.increaseSpStacks(2)
  end
end



#===============================================================================
############################ SS POKEMON MOVES ##################################
#===============================================================================
# Increases allies' PMUP and SMUP by 2 stages, then sets up Tailwind. Requires
# the user to have been hit with at least 2 attacks before using this move
# (can't stack). (B Aura Sphere)
#===============================================================================
class PokeBattle_Move_SP01 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = []
    @phStacks = 2
    @spStacks = 2
    @tailwind = true
  end
  
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.attacksTaken >= 2
    if showMessages
      msg = _INTL("This move requires the user to be hit twice for it to be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectGeneral(user)
    super
    user.attacksTaken = 0
  end
end



#===============================================================================
# Reduces target's Def and Sp. Def by 1 stage if they are paralysed. 
# Can only be used in Electric Terrain. (B Volt Tackle)
#===============================================================================
class PokeBattle_Move_SP02 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if @battle.field.terrain == :Electric
    if showMessages
      msg = _INTL("Electric Terrain needs to be active for this move to be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectGeneral(user)
    user.eachOpposing do |b|
      next if !b.paralyzed?
      b.pbLowerStatStage(:DEFENSE,1,b) if b.pbCanLowerStatStage?(:DEFENSE,b,self)
      b.pbLowerStatStage(:SPECIAL_DEFENSE,1,b) if b.pbCanLowerStatStage?(:SPECIAL_DEFENSE,b,self)
    end
  end
end



#===============================================================================
# Decreases target's attack and Sp. Atk. by 4 stages, leave them confused and
# makes them weaker to Fairy attacks. (B Dazzling Gleam)
#===============================================================================
class PokeBattle_Move_SP03 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.eachOpposing do |b|
      next if b.damageState.substitute
      b.pbLowerStatStage(:ATTACK,4,b) if b.pbCanLowerStatStage?(:ATTACK,b,self)
      b.pbLowerStatStage(:SPECIAL_ATTACK,4,b) if b.pbCanLowerStatStage?(:SPECIAL_ATTACK,b,self)
      b.pbConfuse if b.pbCanConfuse?(user,false,self)
      next if b.effects[PBEffects::FairyDebuff] >= 3
      b.effects[PBEffects::FairyDebuff] += 1
      @battle.pbDisplay(_INTL("{1} became weaker to fairy attacks!",b.pbThis))
    end
  end
end



#===============================================================================
# Type depends on the user's form and reduces resistance against that type on 
# the opponent. (SS Hilbert Techno Blast)
#===============================================================================
class PokeBattle_Move_SP04 < PokeBattle_Move
  def initialize(battle,move)
    super
    @itemTypes = {
       :INSECTDRIVE => :BUG,
       :SHOCKDRIVE  => :ELECTRIC,
       :BURNDRIVE   => :FIRE,
       :CHILLDRIVE  => :ICE,
       :DOUSEDRIVE  => :WATER
    }
  end
  
  def pbBaseType(user)
    ret = :BUG
    if user.itemActive? && user.isSpecies?(:GENESECT)
      choice = @battle.choices[user.index]
      targets = user.pbFindTargets(choice, self, user)
      targets = user.pbChangeTargets(self, user, targets)
      target = targets[0]
      if target != nil
        targetTypes = target.pbTypes(true)
        bestType = nil
        bestMultiplier = 0
        bestMultiplier2 = 1.0 / 0.0 # initialize to infinity
        types = [:WATER,:FIRE,:ELECTRIC,:ICE,:BUG]
        GameData::Type.each do |type|
          # Prevents abilities to make the target immune to some moves
          next if !types.include?(type.id)
          if (type == :WATER && (target.hasActiveAbility?([:DRYSKIN, :STORMDRAIN, :WATERABSORB])||@battle.pbWeather == :HarshSun)) ||
            (type == :FIRE && (target.hasActiveAbility?(:FLASHFIRE)||@battle.pbWeather == :HeavyRain)) ||
            (type == :ELECTRIC && target.hasActiveAbility?([:LIGHTNINGROD, :MOTORDRIVE, :VOLTABSORB]))
            next
          end
          multiplier = targetTypes.inject(1) { |m, targetType| m * Effectiveness.calculate_one(type.id, targetType) }
          multiplier2 = targetTypes.inject(0) { |m, targetType| m + Effectiveness.calculate_one(targetType, type.id) }
          # In case of weather/terrain, account for the new effectiveness  
          if (type == :WATER && [:HarshSun, :Sun].include?(@battle.pbWeather)) ||
            (type == :FIRE && [:HeavyRain, :Rain].include?(@battle.pbWeather))
            multiplier = multiplier / 2   
          end
          if multiplier < bestMultiplier || multiplier == 0
            next
          end
          if multiplier > bestMultiplier
            bestType = type.id
            bestMultiplier = multiplier
            bestMultiplier2 = multiplier2
          elsif multiplier == bestMultiplier && multiplier2 <= bestMultiplier2
            bestType = type.id
            bestMultiplier = multiplier
            bestMultiplier2 = multiplier2
          end
        end
        # Change the move's type to the weakness corresponding to the identified type
        typeArray = {
          :BUG => 0,
          :ELECTRIC => 1,
          :FIRE => 2,
          :ICE => 3,
          :WATER => 4
        }
        newForm = typeArray[bestType.to_sym]
        user.pbChangeForm(newForm,_INTL("{1} changes Drive to be stronger against {2}!", user.pbThis, target.pbThis))
        return bestType
      end
    end
    return ret
  end
  
  def pbAdditionalEffect(user,target)
    return if target.fainted?
    return if target.damageState.substitute
    typeArray = {
      0 => "Bug",
      1 => "Electric",
      2 => "Fire",
      3 => "Ice",
      4 => "Water"
    }
    type = typeArray[user.form]
    @battle.pbDisplay(_INTL("{1} became weaker to {2} attacks!",target.pbThis,type))
    case type
    when "Bug"
      target.effects[PBEffects::BugDebuff] += 1
    when "Electric"
      target.effects[PBEffects::ElectricDebuff] += 1
      return if !target.pbCanParalyze?(user,false,self)
      target.pbParalyze(user)
    when "Fire"
      target.effects[PBEffects::FireDebuff] += 1
      return if !target.pbCanLowerStatStage?(:ATTACK,user,self)
      target.pbLowerStatStage(:ATTACK,1,user)
    when "Ice"
      target.effects[PBEffects::IceDebuff] += 1
      return if !target.pbCanFreeze?(user,false,self) || @battle.pbRandom(100)<50
      target.pbFreeze
    when "Water"
      target.effects[PBEffects::WaterDebuff] += 1
      return if !target.pbCanLowerStatStage?(:DEFENSE,user,self)
      target.pbLowerStatStage(:DEFENSE,1,user)
    end
  end
end



#===============================================================================
# Can only be used after Freeze Shock has been used.
# Decreases the target's Attack, Sp. Attack and Speed by 2 stages each.
# Always hits. Increase PMUP stacks by 1. (B Noble Roar)
#===============================================================================
class PokeBattle_Move_SP05 < PokeBattle_TargetMultiStatDownMove
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.include?(:FREEZESHOCK)
    if showMessages
      msg = _INTL("Freeze Shock needs to be used first.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end

  def ignoresSubstitute?(user); return true; end

  def initialize(battle,move)
    super
    @statDown = [:ATTACK,2,:SPECIAL_ATTACK,2,:SPEED,2]
  end
  
  def pbEffectGeneral(user)
    user.increasePhStacks(1)
    user.movesUsed.delete(:FREEZESHOCK)
  end

  def pbAccuracyCheck(user,target); return true; end
end



#===============================================================================
# Lowers target's Def. by 2 stages and raises all allies' Def. by 2 stages.
# (B Diamond Storm)
#===============================================================================
class PokeBattle_Move_SP06 < PokeBattle_Move_04C
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if @battle.field.zone == :Rock
    if showMessages
      msg = _INTL("A Rock Zone needs to be active for this move to be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user) || !b.pbCanRaiseStatStage?(:DEFENSE,user,self)
      b.pbRaiseStatStage(:DEFENSE,2,user)
    end
  end
end

    
    
#===============================================================================
# Can only be used when at least 1 opposing Pokémon is burned. Increases in
# power if there is an opposing burned target which isn't behind a substitute.
# Increases the user's SMUP stacks for every burned target it hit. (B Hydro Pump)
#===============================================================================
class PokeBattle_Move_SP07 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    burned = 0
    user.eachOpposing do |b|
      next if !b || b.fainted?
      next if !b.burned?
      burned += 1
    end
    if burned > 0
      return true
    else
      if showMessages
        msg = _INTL("There needs to be at least 1 burned opposing Pokémon.")
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
  end
  
  def pbBaseDamage(baseDmg,user,target)
    if target.burned? &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 1.5
    end
    return baseDmg
  end
  
  def pbAdditionalEffect(user,target)
    burned = 0
    user.eachOpposing do |b|
      next if !b || !b.burned? # counting the fainted as that's what PoMas does
      burned += 1
    end
    user.increaseSpStacks(burned)
  end
end



#===============================================================================
# Can't be used when no Weather, Terrain or Zone is active. Always crits if
# the move is B Psycho Cut.
#===============================================================================
class PokeBattle_Move_SP09 < PokeBattle_Move
  def pbCritialOverride(user,target); return @function_code == "SP09" ? 1 : 0; end

  def pbCanChooseMove?(user,commandPhase,showMessages)
    if (@battle.field.weather!=:None) || (@battle.field.terrain!=:None) || (@battle.field.zone!=:None)
      return true
    else
      if showMessages
        msg = _INTL("A Weather, Terrain or Zone needs to be active for this move to be used.")
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
  end
end



#===============================================================================
# Doubles in power when the zone is a Fairy Zone. Harshly lowers the target’s
# Speed by 2 stat ranks and raises the Speed of all allied sync pairs by 2
# stat ranks. (B Electroweb)
#===============================================================================
class PokeBattle_Move_SP08 < PokeBattle_Move_SP09
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if !b.pbCanRaiseStatStage?(:SPEED,b,self) && !b.opposes?(user)
      next if !b.pbCanLowerStatStage?(:SPEED,b,self) && b.opposes?(user)
      b.pbLowerStatStage(:SPEED,2,user) if b.opposes?(user)
      b.pbRaiseStatStage(:SPEED,2,b) if !b.opposes?(user)
    end
  end

  def pbBaseDamage(baseDmg,user,target)
    if @battle.field.zone == :Fairy
      baseDmg *= 2
    end
    return baseDmg
  end
end



#===============================================================================
# Raises all allies Atk. by 2 stages and PMUP by 1 stack. (B Swords Dance)
#===============================================================================
class PokeBattle_Move_SP10 < PokeBattle_Move_SP09
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.pbRaiseStatStage(:ATTACK,2,b) if b.pbCanRaiseStatStage?(:ATTACK,user,self)
      b.increasePhStacks(1)
    end
  end
end



#===============================================================================
# Applies Protect to all aliies, then restores 20% or 30% of all allies' HP and
# returns lowered stat stages to normal if it's raining. (B Protect)
#===============================================================================
class PokeBattle_Move_SP11 < PokeBattle_Move_SP09
  def pbEffectGeneral(user)
    mult = (@battle.field.zone = :Fairy) ? 0.3 : 0.2
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.effects[PBEffects::Protect] = true
      b.effects[PBEffects::ProtectRate] = 1
      if b == user
        @battle.pbDisplay(_INTL("{1} protected itself!", user.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} was protected by {2}!", b.pbThis, user.pbThis))
      end
      b.pbRecoverHP(mult*b.totalhp)
      next if [:HeavyRain, :Rain].include?(@battle.field.weather) || !b.hasLoweredStatStages?
      b.pbResetLoweredStatStages
      @battle.pbDisplay(_INTL("{1}'s lowered stats returned to normal!", user.pbThis))
    end
  end
end



#===============================================================================
# Hits 3 times and raises Crit Rate by 1 stage for each hit that lands.
# (B Triple Axel)
#===============================================================================
class PokeBattle_Move_SP12 < PokeBattle_Move_0BF
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.hp == user.totalhp
    if showMessages
      msg = _INTL("The user needs to be at full hp for this move to be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectWhenDealingDamage(user,target)
    user.raiseCritRate(1)
  end
end



#===============================================================================
# Lower target's Sp. Def by 2 stages. (B Sludge Wave)
#===============================================================================
class PokeBattle_Move_SP13 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    statuses = 0
    user.eachOpposing do |b|
      next if !b || b.fainted?
      next if b.status == :NONE
      statuses += 1
    end
    return true if statuses > 0
    if showMessages
      msg = _INTL("There needs to be at least 1 opposing Pokémon with a status condition.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end

  def pbAdditionalEffect(user,target)
    target.pbLowerStatStage(:SPECIAL_DEFENSE,2,b) if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
    return if target.damageState.substitute
    target.pbPoison(user) if target.pbCanPoison?(user,false,self)
  end
end



#===============================================================================
# Deals 20% more damage if the target has a status condition. (B Overdrive)
#===============================================================================
class PokeBattle_Move_SP14 < PokeBattle_Move_SP09
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.2 if target.status != :NONE
    return baseDmg
  end
end



#===============================================================================
# Can only be used after a non-trainer move has been used.
# Deal 20% more dmg and gain 1 SMUP stack for every -2 Sp. Atk. on every enemy.
# (B Fleur Cannon)
#===============================================================================
class PokeBattle_Move_SP15 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    moves = user.movesUsed.select { |m| m != :SSGLADION }
    return true if moves.length > 0 || !user.pbHasMove?(:SSGLADION)
    if showMessages
      msg = _INTL("{1} needs to use a move first.", user.pbThis)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def calcSpAtkDrop(user)
    minus = 0
    @battle.eachBattler do |b|
      next if !b.opposes?(user)
      minus -= b.stages[:SPECIAL_ATTACK]/2
    end
    return minus
  end
  
  def pbBaseDamage(baseDmg,user,target)
    return baseDmg*(1+calcSpAtkDrop(user)*0.2)
  end
  
  def pbEffectGeneral(user)
    user.increaseSpStacks(calcSpAtkDrop(user))    
  end
end



#===============================================================================
# Can only be used when an opponent has a status condition or is flinching,
# confused or trapped. Applies different effects based on what the target has
# inflicted on it. (B Hex + B Wild Charge)
#===============================================================================
class PokeBattle_Move_SP16 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    statuses = 0
    user.eachOpposing do |b|
      next if !b || b.fainted?
      next if b.status == :NONE && b.effects[PBEffects::Confusion]<=0 &&
              b.effects[PBEffects::Trapping]<=0
      statuses += 1
    end
    if statuses > 0
      return true
    else
      if showMessages
        msg = _INTL("There needs to be at least 1 opposing Pokémon that has a status condition or is confused or trapped.")
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    showAnim = true
    case target.status
    when :PARALYSIS
      if target.pbCanLowerStatStage?(:DEFENSE,user,self)
        target.pbLowerStatStage(:DEFENSE,2,user,showAnim)
        showAnim = false
      end
    when :BURN
      if target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
        target.pbLowerStatStage(:SPECIAL_DEFENSE,2,user,showAnim)
        showAnim = false
      end
    when :POISON
      @battle.eachBattler do |b|
        next if b.opposes?(user)
        b.pbRecoverHP(b.totalhp/10)
      end
      @battle.pbDisplay(_INTL("{1} restored HP for itself and its allies!",user))
    else
      if target.effects[PBEffects::Flinch]
        if target.pbCanLowerStatStage?(:SPEED,user,self)
          target.pbLowerStatStage(:SPEED,2,user,showAnim)
        end
      end
      if target.effects[PBEffects::Trapping]>0
        user.increasePhStacks(1)
      end
      if target.effects[PBEffects::Confusion]>0
        user.increaseSpStacks(1)
      end
    end
  end  
end



#===============================================================================
# Increases team's Def. and Sp. Def by 3 stages and ups the user's stockpile
# by 1 (max. 2). (SSU Giovanni Stockpile)
#===============================================================================
class PokeBattle_Move_SP17 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE,3,:SPECIAL_DEFENSE,3]
  end
  
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::Stockpile]>=2
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!",user.pbThis))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    super
    user.effects[PBEffects::Stockpile] += 1
    user.effects[PBEffects::StockpileDef] += 3
    user.effects[PBEffects::StockpileSpDef] += 3
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",
        user.pbThis,user.effects[PBEffects::Stockpile]))
  end
end



#===============================================================================
# Works like regular Swallow but heal allies too and can't be selected if
# Stockpile hasn't been used. Restores 1 PP to SS (Ultra) Gio's TM. (B Swallow) 
#===============================================================================
class PokeBattle_Move_SP18 < PokeBattle_Move_114
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.effects[PBEffects::Stockpile] > 0
    if showMessages
      msg = _INTL("Stockpile needs to be used first.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectGeneral(user)
    # Restore HP for allies
    hpGain = 0
    user.eachAlly { |b| hpGain += b.pbRecoverHP(b.totalhp/5) }
    if hpGain>0
      @battle.pbDisplay(_INTL("{1} restored HP for its allies.",user.pbThis))
    end
    # Restore HP for self    
    hpGain = 0
    case [user.effects[PBEffects::Stockpile],1].max
    when 1 then hpGain = user.totalhp/2
    when 2 then hpGain = user.totalhp
    end
    if user.pbRecoverHP(hpGain)>0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
    end
    # Remove Stockpile's effects
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
    showAnim = true
    if user.effects[PBEffects::StockpileDef]>0 &&
       user.pbCanLowerStatStage?(:DEFENSE,user,self)
      if user.pbLowerStatStage(:DEFENSE,user.effects[PBEffects::StockpileDef],user,showAnim)
        showAnim = false
      end
    end
    if user.effects[PBEffects::StockpileSpDef]>0 &&
       user.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE,user.effects[PBEffects::StockpileSpDef],user,showAnim)
    end
    user.effects[PBEffects::Stockpile]      = 0
    user.effects[PBEffects::StockpileDef]   = 0
    user.effects[PBEffects::StockpileSpDef] = 0
    # Restore 1 PP for SS (Ultra) Giovanni
    return if !user.pbHasMove?(:SSGIOVANNI2)
    user.eachMove do |m|
      next if m.id != :SSGIOVANNI2 || m.pp != 0
      m.pp = 1
      @battle.pbDisplay(_INTL("{1}'s Trainer Move can be used again!",@battle.pbGetOwnerName(user.index)))
      break
    end
  end
end



#===============================================================================
# Can't be selected if user's Def. or Sp. Def stat increases are less than 6.
# Removes Stockpiled effect (if any) and all Def. and Sp. Def. increases.
# Restores 1 PP to SS (Ultra) Gio's TM. (B Crunch)
#===============================================================================
class PokeBattle_Move_SP19 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.stages[:DEFENSE] + user.stages[:SPECIAL_DEFENSE] >= 6 
    if showMessages
      msg = _INTL("Your Defense and Special Defense need to be maxed out first.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectGeneral(user)
    # Remove Def. and Sp. Def increases
    showAnim = true
    if user.pbCanLowerStatStage?(:DEFENSE,user,self)
      if user.pbLowerStatStage(:DEFENSE,user.stages[:DEFENSE],user,showAnim)
        showAnim = false
      end
    end
    if user.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
      user.pbLowerStatStage(:SPECIAL_DEFENSE,user.stages[:SPECIAL_DEFENSE],user,showAnim)
    end
    if user.effects[PBEffects::Stockpile] > 0
      @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",user.pbThis))
      user.effects[PBEffects::Stockpile]      = 0
      user.effects[PBEffects::StockpileDef]   = 0
      user.effects[PBEffects::StockpileSpDef] = 0
    end
    # Restore 1 PP for SS (Ultra) Giovanni
    return if !user.pbHasMove?(:SSGIOVANNI2)
    user.eachMove do |m|
      if m.id == :SSGIOVANNI2 && m.pp == 0
        m.pp = 1
        @battle.pbDisplay(_INTL("{1}'s Trainer Move can be used again!",@battle.pbGetOwnerName(user.index)))
        break
      end
    end
  end
end



#===============================================================================
# Lower target's Def. and Sp. Def. by 2 stages, apply debuffs on the target
# based on the user's primary type, then raises the user's team speed by 3
# stages. Can't be the first move the user uses. (B Quick Attack)
#===============================================================================
class PokeBattle_Move_NP01 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,2,:SPECIAL_DEFENSE,2]
  end
  
  def flinchingMove?; return true; end
    
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.length > 0
    if showMessages
      msg = _INTL("One other move needs to be used first before this move can be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
    
  def pbAdditionalEffect(user,target)
    super
    if user.type1 == :WATER
      if target.effects[PBEffects::WaterDebuff] < 3
        target.effects[PBEffects::WaterDebuff] += 1
        @battle.pbDisplay(_INTL("{1} became weaker to Water type attacks!",target.pbThis))
      end
    elsif user.type1 == :DARK
      if target.effects[PBEffects::DarkDebuff] < 3
        target.effects[PBEffects::DarkDebuff] += 1
        @battle.pbDisplay(_INTL("{1} became weaker to Dark type attacks!",target.pbThis))
      end
    end
    @battle.eachBattler do |b|
      next if b.opposes?(user) || !b.pbCanRaiseStatStage?(:SPEED,b,self)
      b.pbRaiseStatStage(:SPEED,3,b)
    end    
  end
end



#===============================================================================
# Raises the Evasion of all allies by 2 stages, then applies effects based on
# the user's primary type. (B Double Team)
#===============================================================================
class PokeBattle_Move_NP02 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:EVASION,2]
  end
  
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.length > 0
    if showMessages
      msg = _INTL("One other move needs to be used first before this move can be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
    
  def pbEffectGeneral(user)
    if user.type1 == :WATER
      @battle.pbStartWeather(user,:Rain,true,false)
      @phStacks = 0
      @spStacks = 2
    elsif user.type1 == :DARK
      @battle.pbStartZone(user,:Dark)
      @phStacks = 2
      @spStacks = 0
    end
    super
  end
end



#===============================================================================
# Can't be used until half of the Pokémon's other moves have been used first.
# (NC Galar B Moves)
#===============================================================================
class PokeBattle_Move_NPGB < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.length >= user.moves.length - 2
    if showMessages
      msg = _INTL("Half of the other moves need to be used first before this move can be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
end



#===============================================================================
# Flinches the target. (B Fiery Wrath)
#===============================================================================
class PokeBattle_Move_NP03 < PokeBattle_Move_NPGB
  def flinchingMove?; return true; end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbFlinch(user)
  end
end



#===============================================================================
# Lowers target's Def by 3 stages. (B Thunderous Kick)
#===============================================================================
class PokeBattle_Move_NP04 < PokeBattle_Move_NPGB
  def pbAdditionalEffect(user,target)
    target.pbLowerStatStage(:DEFENSE,3,user) if target.pbCanLowerStatStage?(:DEFENSE,user,self)
  end
end



#===============================================================================
# Raises Def and Sp. Def of all allies by 1 stage. (B Freezing Glare)
#===============================================================================
class PokeBattle_Move_NP05 < PokeBattle_Move_NPGB
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.pbRaiseStatStage(:DEFENSE,1,b) if b.pbCanRaiseStatStage?(:DEFENSE,b,self)
      next if !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE,b,self)
      b.pbRaiseStatStage(:SPECIAL_DEFENSE,1,b)
    end
  end
end



#===============================================================================
# Can only be used when an opponent has a type debuff.
# Freezes the target if the move is B Ice Beam.
#===============================================================================
class PokeBattle_Move_NP06 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    @battle.eachBattler do |b|
      next if !b.opposes?(user)
      if (b.effects[PBEffects::FightingDebuff] ||
          b.effects[PBEffects::FlyingDebuff] ||
          b.effects[PBEffects::PoisonDebuff] ||
          b.effects[PBEffects::GroundDebuff] ||
          b.effects[PBEffects::RockDebuff] ||
          b.effects[PBEffects::BugDebuff] ||
          b.effects[PBEffects::GhostDebuff] ||
          b.effects[PBEffects::SteelDebuff] ||
          b.effects[PBEffects::FireDebuff] ||
          b.effects[PBEffects::WaterDebuff] ||
          b.effects[PBEffects::GrassDebuff] ||
          b.effects[PBEffects::ElectricDebuff] ||
          b.effects[PBEffects::PsychicDebuff] ||
          b.effects[PBEffects::IceDebuff] ||
          b.effects[PBEffects::DragonDebuff] ||
          b.effects[PBEffects::DarkDebuff] ||
          b.effects[PBEffects::FairyDebuff])
        return true
      end
    end
    if showMessages
      msg = _INTL("At least 1 opposing Pokémon needs to have a type debuff applied on it first.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute || @id != :BICEBEAM
    target.pbFreeze if target.pbCanFreeze?(user,false,self)
  end
end



#===============================================================================
# Restores user's HP by 60%, its allies by 30%, removes all status conditions
# and applies Gradual Healing. (B Roost)
#===============================================================================
class PokeBattle_Move_NP07 < PokeBattle_Move_NP06
  def healingMove?;       return true; end

  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      if b.hp < b.totalhp
        factor = (b == user) ? 2 : 1
        b.pbRecoverHP(0.3*b.totalhp*factor)
        @battle.pbDisplay(_INTL("{1}'s HP was restored.",b.pbThis))
      end
      if !b.status == :NONE
        old_status = user.status
        user.pbCureStatus(false)
        case old_status
        when :BURN
          @battle.pbDisplay(_INTL("{1} healed its burn!",user.pbThis))
        when :POISON
          @battle.pbDisplay(_INTL("{1} cured its poisoning!",user.pbThis))
        when :PARALYSIS
          @battle.pbDisplay(_INTL("{1} cured its paralysis!",user.pbThis))
        when :SLEEP
          @battle.pbDisplay(_INTL("{1} woke up!",user.pbThis))
        when :FROZEN
          @battle.pbDisplay(_INTL("{1} thawed out!",user.pbThis))
        end
      end
      next if b.effects[PBEffects::GradualHealing]
      b.effects[PBEffects::GradualHealing] = true
      @battle.pbDisplay(_INTL("{1} gained a restorative aura!",b.pbThis))
    end
  end
end



#===============================================================================
# Doubles stat decreases. (B Flare Blitz)
#===============================================================================
class PokeBattle_Move_NP08 < PokeBattle_Move_NP06
  def pbEffectAgainstTarget(user,target)
    return if !target.hasLoweredStatStages?
    GameData::Stat.each_battle do |s|
      next if target.stages[s.id] >= 0
      target.pbLowerStatStage(s.id, -target.stages[s.id], user)
    end
  end
  
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user,false,self)
  end
end


#===============================================================================
# Can only be used when user's attack has been raised. (B Outrage)
#===============================================================================
class PokeBattle_Move_NP09 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.stages[:ATTACK] > 0
    if showMessages
      msg = _INTL("{1} must have its attack raised to use this attack!",user.pbThis)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
end



#===============================================================================
# Raise all allies' SMUP and PMUP. Can't be used when at low HP. (B Relic Song)
#===============================================================================
class PokeBattle_Move_NP10 < PokeBattle_SleepMove
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.hp >= user.totalhp/3
    if showMessages
      msg = _INTL("{1}'s HP is too low to use this attack!",user.pbThis)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    return if numHits==0
    return if user.fainted? || user.effects[PBEffects::Transform]
    return if @id != :BRELICSONG
    return if !user.isSpecies?(:MELOETTA)
    return if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect>0
    newForm = (user.form+1)%2
    user.pbChangeForm(newForm,_INTL("{1} transformed!",user.pbThis))
    user.increaseSpStacks(1)
    user.increasePhStacks(1)
    user.eachAlly do |b|
      b.increaseSpStacks(1)
      b.increasePhStacks(1)
    end
  end
end



#===============================================================================
# Can't be used twice in a row or on the first turn the user's sent into battle.
# (B Rock Slide)
#===============================================================================
class PokeBattle_Move_NP11 < PokeBattle_Move
  def flinchingMove?; return true if @id==:BROCKSLIDE; end
    
  def pbCanChooseMove?(user,commandPhase,showMessages)
    if user.lastMoveUsed == @id
      if showMessages
        msg = _INTL("{1} can't be used consecutively!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    elsif user.turnCount < 2
      if showMessages
        msg = _INTL("{1} can't be used on the first turn its user is sent in!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false      
    else
      return true
    end
  end
end



#===============================================================================
# Power up move by 10% for every PMUP stack the user has. Lower target's Spd by
# 2 stages and make it weaker to Flying type attacks if the user uses it as its
# 2nd move after switching/being sent into battle. (B Bleakwind Storm)
#===============================================================================
class PokeBattle_Move_NP12 < PokeBattle_Move_NP11
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1 + (user.effects[PBEffects::PhysicalMoveUpNext]/10) if user.effects[PBEffects::PhysicalMoveUpNext] > 0
    return baseDmg
  end
  
  def pbEffectAgainstTarget(user,target)
    target.pbLowerStatStage(:SPEED,2,user)
    if user.turnCount < 3 && target.effects[PBEffects::FlyingDebuff] < 3
      target.effects[PBEffects::FlyingDebuff] += 1
      @battle.pbDisplay(_INTL("{1} became weaker to Flying-type attacks!",target.pbThis))
    end
  end
end



#===============================================================================
# Lower target's Atk and Sp. Atk by 3 stages and make it weaker to Fighting
# type attacks. Ignores target's defensive boosts when dealing damage.
# (B Sacred Sword)
#===============================================================================
class PokeBattle_Move_NP13 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,3,:SPECIAL_ATTACK,3]
  end
  
  def pbCalcAccuracyMultipliers(user,target,multipliers)
    super
    modifiers[:evasion_stage] = 0
  end

  def pbGetDefenseStats(user,target)
    ret1, _ret2 = super
    return ret1, 6   # Def/SpDef stat stage
  end
  
  def pbEffectAgainstTarget(user,target)
    super
    return if target.effects[PBEffects::FightingDebuff] >= 3
    target.effects[PBEffects::FightingDebuff] += 2
    target.effects[PBEffects::FightingDebuff] = 3 if target.effects[PBEffects::FightingDebuff] > 3
    @battle.pbDisplay(_INTL("{1} became weaker to Fighting-type attacks!",target.pbThis))
  end
end



#===============================================================================
# Can only be used in Heavy Rain. Causes the target to flinch and lower its
# Sp. Def. by 2 stages. (B Origin Pulse)
#===============================================================================
class PokeBattle_Move_NP14 < PokeBattle_FlinchMove    
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if @battle.field.weather == :HeavyRain
    if showMessages
      msg = _INTL("{1} can only be used in Heavy Rain!",@name)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false     
  end
  
  def pbAdditionalEffect(user, target)
    return if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
    target.pbLowerStatStage(:SPECIAL_DEFENSE,2,user)
  end
end



#===============================================================================
# Can only be used under Harsh Sun. Can't be used consecutively or on the
# first turn the user's sent into battle. Causes the target to flinch and
# lower its Def. by 3 stages. (B Precipice Blades)
#===============================================================================
class PokeBattle_Move_NP15 < PokeBattle_FlinchMove
  def pbCanChooseMove?(user,commandPhase,showMessages)
    if user.lastMoveUsed == @id
      if showMessages
        msg = _INTL("{1} can't be used consecutively!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    elsif user.turnCount < 2
      if showMessages
        msg = _INTL("{1} can't be used on the first turn its user is sent in!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    elsif @battle.field.weather != :HarshSun
      if showMessages
        msg = _INTL("{1} can only be used under Harsh Sun!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    return true
  end
  
  def pbAdditionalEffect(user, target)
    return if !target.pbCanLowerStatStage?(:DEFENSE,user,self)
    target.pbLowerStatStage(:DEFENSE,3,user)
  end
end



#===============================================================================
# Can't be used consecutively or on the first turn the user's sent into battle.
# Lower targets' Def by 3 stages. (B Sunsteel Strike)
#===============================================================================
class PokeBattle_Move_NP16 < PokeBattle_Move_163
  def pbCanChooseMove?(user,commandPhase,showMessages)
    if user.lastMoveUsed == @id
      if showMessages
        msg = _INTL("{1} can't be used consecutively!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    elsif user.turnCount < 2
      if showMessages
        msg = _INTL("{1} can't be used on the first turn its user is sent in!",@name)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
    return true
  end
  
  def pbAdditionalEffect(user, target)
    return if !target.pbCanLowerStatStage?(:DEFENSE,user,self)
    target.pbLowerStatStage(:DEFENSE,3,user)
  end
end



#===============================================================================
# Can only be used after another move has been used.
# Lower targets' Sp. Def by 3 stages. (B Moongeist Beam)
#===============================================================================
class PokeBattle_Move_NP17 < PokeBattle_Move_163
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.length > 0
    if showMessages
      msg = _INTL("One other move needs to be used first before this move can be used.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbAdditionalEffect(user, target)
    return if !target.pbCanLowerStatStage?(:SPECIAL_DEFENSE,user,self)
    target.pbLowerStatStage(:SPECIAL_DEFENSE,3,user)
  end
end

