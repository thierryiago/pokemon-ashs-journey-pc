#===============================================================================
############################ AS TRAINER MOVES ##################################
#===============================================================================
# Increase user's PMUP stacks by 2 stages and apply Gradual Heaing to self.
# Increase user's SYUP stacks by 5. (AS Cynthia)
#===============================================================================
class PokeBattle_Move_RT00 < PokeBattle_Move_NT08
  def pbEffectGeneral(user)
    user.increasePhStacks(2)
    return if user.effects[PBEffects::GradualHealing]
    user.effects[PBEffects::GradualHealing] = true
    @battle.pbDisplay(_INTL("{1} gained a restorative aura!",user.pbThis))
    user.increaseSyStacks(5)
  end
end



#===============================================================================
# Maxes out Atk and Crit Rate of all Pokémon on user's side of the field.
# Increase team's SYUP stacks by 3. (AS Steven)
#===============================================================================
class PokeBattle_Move_RT01 < PokeBattle_OwnSideMultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,6]
    @crit = 3
  end
  
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      b.increaseSyStacks(3)
    end
  end
end



#===============================================================================
# Maxes out Atk., Sp. Atk. and Crit Rate and applies Gradual Healing to self.
# User loses 20% of its current HP. (AS Lance)
#===============================================================================
class PokeBattle_Move_RT02 < PokeBattle_Move_NT08
  def pbEffectGeneral(user)
    super
    user.pbReduceHP(0.2*user.hp)
    return if user.effects[PBEffects::GradualHealing]
    user.effects[PBEffects::GradualHealing] = true
    @battle.pbDisplay(_INTL("{1} gained a restorative aura!",user.pbThis))
  end
end



#===============================================================================
# Maxes out Sp. Atk and Crit and raises Acc. by 1 stage. (AS N)
#===============================================================================
class PokeBattle_Move_RT03 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6,:ACCURACY,1]
    @crit = 3
  end
end



# AS Leon has the same Trainer Move as Anni Lillie's

#===============================================================================
# Maxes out Sp. Atk and increase side's Sync Energy by 1. (AS Alder)
#===============================================================================
class PokeBattle_Move_RT04 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPECIAL_ATTACK,6]
  end
  
  def pbEffectGeneral(user)
    super
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by 1!", user.pbThis))
  end
end



#===============================================================================
# Maxes out Def and Sp. Def and increase side's Sync Energy by 2. (AS Silver)
#===============================================================================
class PokeBattle_Move_RT05 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:DEFENSE, 6, :SPECIAL_DEFENSE,6]
  end
  
  def pbEffectGeneral(user)
    super
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 2
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by 2!", user.pbThis))
  end
end



#===============================================================================
# If user would be KO'd this round, it survives with 1HP instead. Increases
# side's sync energy based on how many SYUP stacks it has (max 4). (AS Ethan)
#===============================================================================
class PokeBattle_Move_RT06 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::Endure] = true
    @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
    incr = (user.effects[PBEffects::SyncMoveUpNext] / 3 ) + 1
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += incr
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by {2}!", user.pbThis, incr))
  end
end



#===============================================================================
# Increase side's sync energy by 1 and user's SYUP stacks by 5. If user is Mega
# Pidgeot, restore 1 PP to Almighty Air Slash. (AS Blue)
#===============================================================================
class PokeBattle_Move_RT07 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by 1!", user.pbThis))
    user.increaseSyStacks(5)
    return if !user.pbHasMove?(:AAIRSLASH)
    user.eachMove do |m|
      next if m.id != :AAIRSLASH || m.pp != 0
      m.pp = 1
      @battle.pbDisplay(_INTL("{1}'s Almighty Air Slash can be used again!",user.pbThis))
      break
    end
  end
end



#===============================================================================
# Increase side's sync energy by 1 and user's PMUP and SYUP stacks by 2 and 4
# respectively. (AS Brock)
#===============================================================================
class PokeBattle_Move_RT08 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by 1!", user.pbThis))
    user.increasePhStacks(2)
    user.increaseSyStacks(4)
  end
end



#===============================================================================
# User protects itself from damage and cannot be KO'ed for the rest of the turn.
# Increase user's SYUP stacks by 5. (AS Misty)
#===============================================================================
class PokeBattle_Move_RT09 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::Protect] = true
    @battle.pbDisplay(_INTL("{1} protected itself!", user.pbThis))
    user.increaseSyStacks(5)
  end
end



#===============================================================================
############################ AS POKEMON MOVES ##################################
#===============================================================================
# Can only be used after the user creates a sandstorm. Lowers the target's
# Def. by 1 stage. (Almighty Rending Earthquake)
#===============================================================================
class PokeBattle_Move_RP00 < PokeBattle_Move_043
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.include?(:SANDSTORM)
    if showMessages
      msg = _INTL("This move can only be used after the user has set a sandstorm.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
end



#===============================================================================
# Can only be used after the user has used 1 move since entering the field.
# Lowers the target's Def. and Sp. Def. by 2 stages and raises the Def. and
# Sp. Def. of the user and its allies by the same amount.
# (Almighty Flash Bullet Punch)
#===============================================================================
class PokeBattle_Move_RP01 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,2,:SPECIAL_DEFENSE,2]
  end
  
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.length > 0
    if showMessages
      msg = _INTL("This move can only be used after the user has used at least 1 move.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      # same stats as statdown so may as well reuse it
      showAnim = true
      for i in 0...@statDown.length/2
        next if !b.pbCanRaiseStatStage?(@statDown[i*2],user,self)
        if b.pbRaiseStatStage(@statDown[i*2],@statDown[i*2+1],user,showAnim)
          showAnim = false
        end
      end
    end
  end
end



#===============================================================================
# Can only be used turn 3 onwards. The more the target's Def and Sp. Def are
# lowered, the more damage this move does. (Almighty Roar Hyper Beam)
#===============================================================================
class PokeBattle_Move_RP02 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.turnCount >= 3
    if showMessages
      msg = _INTL("This move can only be used after the user has been in battle for 2 full turns.")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbBaseDamage(baseDmg,user,target)
    baseDmg = baseDmg*(1-0.05*target.stages[:DEFENSE]) if target.stages[:DEFENSE] < 0
    baseDmg = baseDmg*(1-0.05*target.stages[:SPECIAL_DEFENSE]) if target.stages[:SPECIAL_DEFENSE] < 0
    return baseDmg
  end
end



#===============================================================================
# Can only be used if there is a burned opponent. Burns the target.
# (Almighty Fire Blast)
#===============================================================================
class PokeBattle_Move_RP03 < PokeBattle_Move_SP07
  def pbBaseDamage(baseDmg,user,target)
    return baseDmg
  end
  
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbBurn(user) if target.pbCanBurn?(user,false,self)
  end
end



#===============================================================================
# Lower target's Acc. by 1 stage and can only be used if there is a type debuff
# on the opposing field. (Almighty Obsidian Night Daze)
#===============================================================================
class PokeBattle_Move_RP04 < PokeBattle_Move_NP06
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbLowerStatStage(:ACCURACY,1,user) if target.pbCanLowerStatStage?(:ACCURACY,user,self)
  end
end



#===============================================================================
# Can't be used on the first turn the user is in battle. Sets Bug Zone.
# (Almighty Sun Hyper Beam)
#===============================================================================
class PokeBattle_Move_RP05 < PokeBattle_Move    
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.turnCount >= 2
    if showMessages
      msg = _INTL("{1} can't be used on the first turn its user is sent in!",@name)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false      
  end
  
  def pbAdditionalEffect(user,target)
    return if @battle.field.zone == :Bug
    @battle.pbStartZone(user, :Bug)
  end
end



#===============================================================================
# Can only be used if the user's HP is above 50%. Burns the target.
# Gains the following effects based on how much PP it has when used:
# - 3 PP: Set Sun with extended duration
# - 2 PP: Lower target's Def. and Sp. Def by 3
# - 1 PP: Apply Endure to the user
# (Almighty Skies Sacred Fire)
#===============================================================================
class PokeBattle_Move_RP06 < PokeBattle_BurnMove
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.hp >= user.totalhp/2
    if showMessages
      msg = _INTL("{1} can only be used when the user has more than 50% of its HP!",@name)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false      
  end

  def pbAdditionalEffect(user,target)
    case @pp
    when 3
      @battle.pbStartWeather(user, :Sun, true, false, 8)
    when 1
      user.effects[PBEffects::Endure] = true
      @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
    end
    super
    return if @pp != 2
    target.pbLowerStatStage(:DEFENSE,3,user) if target.pbCanLowerStatStage?(:ATTACK,user)
    target.pbLowerStatStage(:SPECIAL_DEFENSE,3,user) if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user)
  end
end



#===============================================================================
# Can only be used when the user has SYUP stacks. Increases in power when the
# target has a status condition and always makes it flinch. Always crits.
# (Almighty Seas Aeroblast)
#===============================================================================
class PokeBattle_Move_RP07 < PokeBattle_FlinchMove
  def pbCritialOverride(user,target); return 1; end

  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.effects[PBEffects::SyncMoveUpNext] > 0
    if showMessages
      msg = _INTL("{1} can only be used when its next Sync Move will be powered up!",@name)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false      
  end
  
  def pbBaseDamage(baseDmg,user,target)
    if target.status != :NONE &&
       (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 1.5
    end
    return baseDmg
  end
end



#===============================================================================
# Confuses the target. If user is Mega Pidgeot, increases in power by 50%.
# Otherwise, increase Sync Energy by 1. (Sacred Hurricane)
#===============================================================================
class PokeBattle_Move_RP08 < PokeBattle_ConfuseMove
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1.5 if user.form == 1 && user.isSpecies?(:PIDGEOT)
    return baseDmg
  end
  
  def pbAdditionalEffect(user,target)
    super
    return if user.form != 0 || !user.isSpecies?(:PIDGEOT)
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += 1
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by 1!", user.pbThis))
  end
end



#===============================================================================
# Lower target's Def. by 2 stages. Raise user's Def. by 2 stages. 30% chance to
# make the target flinch. (Almight Rock Slide)
#===============================================================================
class PokeBattle_Move_RP09 < PokeBattle_Move_04C
  def flinchingMove?; return true; end
  
  def pbEffectGeneral(user)
    @battle.eachBattler do |b|
      next if b.opposes?(user)
      user.pbRaiseStatStage(:DEFENSE,2,user) if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
    end
  end
  
  def pbAdditionalEffect(user,target)
    super
    return if target.damageState.substitute || battle.pbRandom(10) >= 3 # 30% chance
    target.pbFlinch(user)    
  end
end



#===============================================================================
# Can only be used when the user's Def. has been raised. The more the user's
# Def. has been raised, the stronger the move, the more sync energy generated
# (max 3) and the more stacks of PMUP it gets. Removes Def. increase after use.
# Always crits. (Almighty Stone Edge)
#===============================================================================
class PokeBattle_Move_RP10 < PokeBattle_Move
  def pbCritialOverride(user,target); return 1; end

  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.stages[:DEFENSE] > 0
    if showMessages
      msg = _INTL("{1} can only be used when it has a Defense increase!",@name)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false      
  end
  
  def halfDef(user); return user.stages[:DEFENSE] / 2; end
    
  def pbBaseDamage(baseDmg,user,target)
    return baseDmg*(1+halfDef(user)*0.2)
  end

  def pbAdditionalEffect(user,target)
    return if user.stages[:DEFENSE] <= 0
    stacks = halfDef(user)
    user.pbOwnSide.effects[PBEffects::SyncEnergy] += stacks
    @battle.pbDisplay(_INTL("{1} side's Sync Energy increased by {2}!", user.pbThis, stacks))
    user.increasePhStacks(stacks)
    user.stages[:DEFENSE] = 0
  end
end



#===============================================================================
# Lower target's Sp. Def. and Spd. by 2 stages. (Almighty Bubble Beam)
#===============================================================================
class PokeBattle_Move_RP11 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_DEFENSE,2,:SPEED,2]
  end
end



#===============================================================================
# Can only be used after the user has used 1 move. Confuses the target.
# (Almighty Hydro Pump)
#===============================================================================
class PokeBattle_Move_RP12 < PokeBattle_ConfuseMove
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if user.movesUsed.length > 0
    if showMessages
      msg = _INTL("{1} can only be used after {2} has used another move first!",@name,user.pbThis)
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
end



#===============================================================================
# Generic Sync Move
# Has the following properties:
# Can be used and selected even when the user is sleeping or frozen
# - Can only be used if the user's side has at least 4 sync energy
# - Thaws/Wakes user up when on use
# - Ignores Ghost and Dark type immunities (need to work on Ground and Flying)
# - Each stack of SyncMoveUpNext power up the Sync Move by 10% and are consumed
#   on use
#===============================================================================
class PokeBattle_Move_SM00 < PokeBattle_Move
  def usableWhenAsleep?; return true; end

  def pbCanChooseMove?(user,commandPhase,showMessages)
    if user.pbOwnSide.effects[PBEffects::SyncEnergy] < 4
      if showMessages
        msg = _INTL("{1} doesn't have enough energy to use its Sync Move!",user.pbThis)
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    else
      return true
    end
  end

  def pbMoveFailed?(user,targets)
    if user.pbOwnSide.effects[PBEffects::SyncEnergy] < 4
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  def pbBaseDamage(baseDmg,user,target)
    baseDmg *= 1 + (user.effects[PBEffects::SyncMoveUpNext] * 0.1)
    case @id
    when :DOUTRAGE
      baseDmg *= 1 + (target.stages[:SPECIAL_DEFENSE] * -0.1) if target.stages[:SPECIAL_DEFENSE] < 0
    end
    return baseDmg
  end
  
  def pbOnStartUse(user,targets)
    user.pbCureStatus(true) if user.status == :SLEEP # Make user wake up
    user.eachOpposing do |b|
      b.effects[PBEffects::MiracleEye] = true
      b.effects[PBEffects::Foresight]  = true
    end
    case @id
    when :DEARTHQUAKE
      megaIfPossible(user, :GARCHOMP)
    when :DMETEORMASH
      megaIfPossible(user, :METAGROSS)
    when :DHURRICANE
      megaIfPossible(user, :PIDGEOT)
      move_idx = user.pbGetMoveIdx(:AIRSLASH)
      return if move_idx == -1
      user.moves[move_idx] = (PokeBattle_Move.from_pokemon_move(@battle,
        Pokemon::Move.new(:AAIRSLASH)))
    end
  end
    
  def pbEffectGeneral(user)
    user.effects[PBEffects::SyncMoveUpNext] = 0
    user.pbOwnSide.effects[PBEffects::SyncEnergy] = 0
    user.eachOpposing do |b|
      b.effects[PBEffects::MiracleEye] = false
      b.effects[PBEffects::Foresight]  = false
    end
  end
  
  def pbAdditionalEffect(user,target)
    case @id
    when :DFIREBLAST
      return if target.damageState.substitute || !target.pbCanBurn?(user,false,self)
      target.pbBurn(user)
    when :DEARTHQUAKE
      user.increasePhStacks(2)
    when :DMETEORMASH
      @battle.eachBattler do |b|
        next if b.opposes?(user) || !b.canHeal?
        b.pbRecoverHP(b.totalhp/5)
        @battle.pbDisplay(_INTL("{1} healed some of its HP!",b.pbThis))
      end
    when :DNIGHTDAZE
      10.times do
        stat = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK,
                :SPECIAL_DEFENSE, :SPEED].sample
        target.pbLowerStatStage(stat,1,user) if target.pbCanLowerStatStage?(stat,user,self)
      end
    when :DBUGBUZZ
      user.increaseSpStacks(2)
#      user.pbOwnSide.effects[PBEffects::SyncEnergy] += 3
    when :DSACREDFIRE
      user.effects[PBEffects::Protect] = true
      @battle.pbDisplay(_INTL("{1} protected itself!", user.pbThis))
    when :DHURRICANE
      user.effects[PBEffects::Endure] = true
      @battle.pbDisplay(_INTL("{1} braced itself!", user.pbThis))
    when :DROCKSLIDE
      user.increasePhStacks(2)
      @battle.pbStartZone(user, :Rock)
    when :DBUBBLEBEAM
      user.increaseSpStacks(2)
      user.moves[1].pp += 1 if user.moves[1].pp < 1
    end
  end
  
  def megaIfPossible(user, species)
    return if user.form != 0 || !user.isSpecies?(species)
    @battle.pbMegaEvolve(user.index)
  end
end




