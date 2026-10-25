#===============================================================================
############################ DESPAIR CHALLENGE #################################
#===============================================================================
# Restores user to max HP.
#===============================================================================
class PokeBattle_Move_LUC1 < PokeBattle_HealingMove
  def pbHealAmount(user)
    return user.totalhp
  end
end



#===============================================================================
# OP Judgment
#===============================================================================
class PokeBattle_Move_LUC2 < PokeBattle_Move_09F
  def pbOnStartUse(user,targets)
    trainer = _INTL("{1}",battle.pbGetOwnerName(user.index))
    return if trainer != "Grandeur Club Vice Luc-ker"
    return if !user.isSpecies?(:ARCEUS) || !user.hasActiveAbility?(:MULTITYPE) || !user.hasActiveItem?(:LEGENDPLATE)
    $game_system.bgm_play_internal(pbResolveAudioFile("Wildfire.ogg"),0) if !$game_switches[670]
    $game_switches[670] = true
    user.eachOpposing do |b|
      case user.form
      when 1
        @battle.pbStartZone(user, :Fighting, false)
        if b.effects[PBEffects::FightingDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Fighting resistance can't be lowered any further!"))
        else
          b.effects[PBEffects::FightingDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Fighting type attacks!",b.pbThis))
        end
      when 2
        if b.effects[PBEffects::FlyingDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Flying resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Flying, false)
          b.effects[PBEffects::FlyingDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Flying type attacks!",b.pbThis))
        end
      when 3
        if b.effects[PBEffects::PoisonDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Poison resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Poison, false)
          b.effects[PBEffects::PoisonDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Poison type attacks!",b.pbThis))
        end
      when 4
        if b.effects[PBEffects::GroundDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Ground resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Ground, false)
          b.effects[PBEffects::GroundDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Ground type attacks!",b.pbThis))
        end
      when 5
        if b.effects[PBEffects::RockDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Rock resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Rock, false)
          b.effects[PBEffects::RockDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Rock type attacks!",b.pbThis))
        end
      when 6
        if b.effects[PBEffects::BugDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Bug resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Bug, false)
          b.effects[PBEffects::BugDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Bug type attacks!",b.pbThis))
        end
      when 7
        if b.effects[PBEffects::GhostDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Ghost resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Ghost, false)
          b.effects[PBEffects::GhostDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Ghost type attacks!",b.pbThis))
        end
      when 8
        if b.effects[PBEffects::SteelDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Steel resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Steel, false)
          b.effects[PBEffects::SteelDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Steel type attacks!",b.pbThis))
        end
      when 10
        if b.effects[PBEffects::FireDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Fire resistance can't be lowered any further!"))
        else
          @battle.pbStartWeather(user, :Sun, false, true)
          b.effects[PBEffects::FireDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Fire type attacks!",b.pbThis))
        end
      when 11
        if b.effects[PBEffects::WaterDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Water resistance can't be lowered any further!"))
        else
          @battle.pbStartWeather(user, :Rain, false, true)
          b.effects[PBEffects::WaterDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Water type attacks!",b.pbThis))
        end
      when 12
        if b.effects[PBEffects::GrassDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Grass resistance can't be lowered any further!"))
        else
          @battle.pbStartTerrain(user, :Grassy, false)
          b.effects[PBEffects::GrassDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Grass type attacks!",b.pbThis))
        end
      when 13
        if b.effects[PBEffects::ElectricDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Electric resistance can't be lowered any further!"))
        else
          @battle.pbStartTerrain(user, :Electric, false)
          b.effects[PBEffects::ElectricDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Electric type attacks!",b.pbThis))
        end
      when 14
        if b.effects[PBEffects::PsychicDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Psychic resistance can't be lowered any further!"))
        else
          @battle.pbStartTerrain(user, :Psychic, false)
          b.effects[PBEffects::PsychicDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Psychic type attacks!",b.pbThis))
        end
      when 15
        if b.effects[PBEffects::IceDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Ice resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Ice, false)
          b.effects[PBEffects::IceDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Ice type attacks!",b.pbThis))
        end
      when 16
        if b.effects[PBEffects::DragonDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Dragon resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Dragon, false)
          b.effects[PBEffects::DragonDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Dragon type attacks!",b.pbThis))
        end
      when 17
        if b.effects[PBEffects::DarkDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Dark resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Dark, false)
          b.effects[PBEffects::DarkDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Dark type attacks!",b.pbThis))
        end
      when 18
        if b.effects[PBEffects::FairyDebuff] >= 3
          @battle.pbDisplay(_INTL("{1}'s Fairy resistance can't be lowered any further!"))
        else
          @battle.pbStartZone(user, :Fairy, false)
          b.effects[PBEffects::FairyDebuff] += 1
          @battle.pbDisplay(_INTL("{1} became weaker to Fairy type attacks!",b.pbThis))
        end
      end
    end
  end
end



#===============================================================================
# Sets up Stealth Rock and grants the user the Ghost type. (Ghostly Stealth Rock)
#===============================================================================
class PokeBattle_Move_LUC3 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::StealthRock] = true
    @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
       user.pbOpposingTeam(true)))
    user.effects[PBEffects::Type3] = :GHOST
    typeName = GameData::Type.get(:GHOST).name
    @battle.pbDisplay(_INTL("{1}'s type changed to {2}!",user.pbThis,typeName))
  end
end



#===============================================================================
# Entry hazard. Lays Spikes and Toxic Spikes on the opposing side
# (max. 3 layers). (Multi-Coloured Spikes)
#===============================================================================
class PokeBattle_Move_LUC4 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::Spikes]>=3
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::Spikes] = 3
    @battle.pbDisplay(_INTL("Spikes were scattered all around {1}'s feet!",
       user.pbOpposingTeam(true)))
    if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] < 2
      user.pbOpposingSide.effects[PBEffects::ToxicSpikes] = 2
      @battle.pbDisplay(_INTL("Toxic Spikes were scattered all around {1}'s feet!",
        user.pbOpposingTeam(true)))
    end
  end
end



#===============================================================================
# KOes the user to deal 90% of the target(s)' HP. (Giga Explosion)
#===============================================================================
class PokeBattle_Move_LUC5 < PokeBattle_Move
  def worksWithNoTargets?;     return true; end
  def pbNumHits(user,targets); return 1;    end

  def pbFixedDamage(user,target)
    damage = 0.9*target.totalhp
    if !@battle.moldBreaker
      bearer = @battle.pbCheckGlobalAbility(:DAMP)
      if bearer!=nil
        damage /= 2
        @battle.pbShowAbilitySplash(bearer)
        if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
          @battle.pbDisplay(_INTL("{1} halves the incoming damage!",bearer.pbThis))
        else
          @battle.pbDisplay(_INTL("The damage is being halved because of {1}'s {2}!",
             bearer.pbThis(true),bearer.abilityName))
        end
        @battle.pbHideAbilitySplash(bearer)
      end
    end
    if target.effects[PBEffects::Protect] || target.effects[PBEffects::Obstruct] || 
      target.effects[PBEffects::KingsShield] || target.effects[PBEffects::SpikyShield] ||
      target.effects[PBEffects::BanefulBunker] || target.pbOwnSide.effects[PBEffects::WideGuard]
      damage /= 2
      @battle.pbDisplay(_INTL("{1} couldn't fully protect itself!",target.pbThis))
    end
    return damage
  end

  def pbCalcDamage(user,target,numTargets=1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user,target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
  end

  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
  end
end



#===============================================================================
# Make ghost types lose their immunity to Normal and Fighting moves.
# (Spirit Bomb Aura Sphere)
#===============================================================================
class PokeBattle_Move_LUC6 < PokeBattle_Move
  def pbOnStartUse(user,targets)
    user.eachOpposing do |b|
      b.effects[PBEffects::Foresight] = true
    end
	end
end



#===============================================================================
# Deal damage equal to half the target's max HP. (Cleave)
#===============================================================================
class PokeBattle_Move_LUC7 < PokeBattle_FixedDamageMove
  def pbFixedDamage(user,target)
    return (target.totalhp/2.0).round
  end
end



#===============================================================================
# Lower target's Def. by 6 stages and restore half the user's max HP. 
# Can't be used before taking 4 hits. (GG Giga Impact)
#===============================================================================
class PokeBattle_Move_LUC8 < PokeBattle_TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,6]
  end
  
  def healingMove?;       return true; end
  
  def pbCanChooseMove?(user,commandPhase,showMessages)
    if user.attacksTaken >= 4
      return true
    else
      if showMessages
        msg = _INTL("This move requires the user to be hit 4 times for it to be used.")
        (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
      end
      return false
    end
  end
  
  def pbEffectGeneral(user)
    user.pbRecoverHP(user.totalhp/2.0)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",user.pbThis))
  end
end



#===============================================================================
# Hits 5 times. Power is multiplied by the hit number. (Thousand Sever)
# An accuracy check is performed for each hit.
#===============================================================================
class PokeBattle_Move_DH01 < PokeBattle_Move_0BF
  def pbNumHits(user,targets); return 5;    end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    hitNum = 0 # Same anim
    super
  end
end



#===============================================================================
# Counters a physical move used against the user this round, with 2x the power.
# Disables the last move the target used. (Disarm)
#===============================================================================
class PokeBattle_Move_DH02 < PokeBattle_Move
  def ignoresSubstitute?(user); return true; end

  def pbFailsAgainstTarget?(user,target)
    if target.effects[PBEffects::Disable]>0 || !target.lastRegularMoveUsed
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return true if pbMoveFailedAromaVeil?(user,target)
    canDisable = false
    target.eachMove do |m|
      next if m.id!=target.lastRegularMoveUsed
      next if m.pp==0 && m.total_pp>0
      canDisable = true
      break
    end
    if !canDisable
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbAddTarget(targets,user)
    t = user.effects[PBEffects::CounterTarget]
    return if t<0 || !user.opposes?(t)
    user.pbAddTarget(targets,user,@battle.battlers[t],self,false)
  end

  def pbMoveFailed?(user,targets)
    if targets.length==0
      @battle.pbDisplay(_INTL("But there was no target..."))
      return true
    end
    return false
  end

  def pbFixedDamage(user,target)
    dmg = user.effects[PBEffects::Counter]*2
    dmg = 1 if dmg==0
    return dmg
  end
  
  def pbCalcDamage(user,target,numTargets=1)
    target.damageState.critical   = false
    target.damageState.calcDamage = pbFixedDamage(user,target)
    target.damageState.calcDamage = 1 if target.damageState.calcDamage<1
  end

  def pbEffectAgainstTarget(user,target)
    return if target.fainted?
    target.effects[PBEffects::Disable]     = 5
    target.effects[PBEffects::DisableMove] = target.lastRegularMoveUsed
    @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",target.pbThis,
       GameData::Move.get(target.lastRegularMoveUsed).name))
    target.pbItemStatusCureCheck
  end
end
  


#===============================================================================
# Attacks the target. If it has less than 50% of its HP, KO it instead.
# (Bloodshed Joust)
#===============================================================================
class PokeBattle_Move_DH03 < PokeBattle_Move
  def pbOnStartUse(user,targets)
    target = targets[0]
    return if target.hp >= target.totalhp/2
    target.hp = 0
    target.pbFaint
    return
  end

  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    return if targets[0].fainted?
    super
  end
end



#===============================================================================
# Guarantees a crit next turn (only) and raises the user's attack by 1 stage.
# (Conqueror's Aura)
#===============================================================================
class PokeBattle_Move_DH04 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::ConquerorsAura] = 1
    @battle.pbDisplay(_INTL("{1}'s will land a critical hit next turn!",user.pbThis))
    if user.pbCanRaiseStatStage?(:ATTACK,user,self)
      user.pbRaiseStatStage(:ATTACK,1,user)
    end
  end
end
  
    
    
#===============================================================================
# Randomly lowers 3 of the target's stats. (Tainted Flakes)
#===============================================================================
class PokeBattle_Move_DH05 < PokeBattle_Move  
  def pbEffectAgainstTarget(user,target)
    return if target.damageState.substitute
    stats = [:ATTACK, :DEFENSE, :SPECIAL_ATTACK, :SPECIAL_DEFENSE, :SPEED, :ACCURACY, :EVASION]
    stats = stats.sample(3)
    stats.each do |stat|
      next if !target.pbCanLowerStatStage?(stat,user,self)
      target.pbLowerStatStage(stat,1,user)
    end
  end
end

    
  
#===============================================================================
# Traps the target and lowers its Speed and Evasion by 3 stages. (Cryo Cage)
#===============================================================================
class PokeBattle_Move_DH06 < PokeBattle_Move_0CF
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbLowerStatStage(:SPEED,3,user) if target.pbCanLowerStatStage?(:SPEED,user,self)
    target.pbLowerStatStage(:EVASION,3,user) if target.pbCanLowerStatStage?(:EVASION,user,self)
  end
end



#===============================================================================
# The user heals 1/8 of its HP. (Hunger Times)
#===============================================================================
class PokeBattle_Move_DH07 < PokeBattle_HealingMove
  def pbHealAmount(user); return (user.totalhp/8.0);    end
end



#===============================================================================
# Negates all physical attacks against the user. (Negation: Physical)
#===============================================================================
class PokeBattle_Move_DH08 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::PhysNeg] = true
    @battle.pbDisplay(_INTL("{1} negates all physical attacks against itself!",user.pbThis))
  end
end



#===============================================================================
# Negates all special attacks against the user. (Negation: Special)
#===============================================================================
class PokeBattle_Move_DH09 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::SpecNeg] = true
    @battle.pbDisplay(_INTL("{1} negates all special attacks against itself!",user.pbThis))
  end
end



#===============================================================================
# Negates all status attacks against the user. (Negation: Status)
#===============================================================================
class PokeBattle_Move_DH10 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.effects[PBEffects::StatusNeg] = true
    @battle.pbDisplay(_INTL("{1} negates all status attacks against itself!",user.pbThis))
  end
end



#===============================================================================
# Reduces countdown for Destiny Reaping. (UUDDLRLRBAS)
#===============================================================================
class PokeBattle_Move_DH11 < PokeBattle_Move
  def pbEffectGeneral(user)
    return if !user.hasActiveAbility?(:DESTINYREAPING)
    user.effects[PBEffects::DestinyReaping] -= 1
    @battle.pbDisplay(_INTL("{1} reduced its kill countdown!",user.pbThis))
  end
end



#===============================================================================
# Gains effects based on how many Disasters active. (Stormcall Blitz)
#===============================================================================
class PokeBattle_Move_DH12 < PokeBattle_TwoTurnMove
  def pbIsChargingTurn?(user)
    ret = super
    if !user.effects[PBEffects::TwoTurnAttack]
      if @battle.field.disasters.length >= 1
        @powerHerb = false
        @chargingTurn = false
        @damagingTurn = true
      end
    end
    return ret
  end

  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} began charging up electricity!",user.pbThis))
  end
  
  def pbBaseAccuracy(user,target)
    return 0 if !@damagingTurn
    return 100 if @battle.field.disasters.length >= 2
    return super
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbFlinch(user) if @battle.field.disasters.length >= 3 && rand(100) <= 20
  end

  def pbBaseDamage(baseDmg,user,target)
    if @battle.field.disasters.length >= 4
      baseDmg *= 2
    end
    return baseDmg
  end
end
    


#===============================================================================
# Gains effects based on how many Disasters active. (Roaring Torrents)
#===============================================================================
class PokeBattle_Move_DH13 < PokeBattle_Move
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbParalyze(user) if @battle.field.disasters.length >= 1 && rand(100) <= 10
    target.pbBurn(user) if @battle.field.disasters.length >= 4 && rand(100) <= 10
  end
  
  def pbAddTarget(targets,user)
    if @battle.field.disasters.length >= 0
      opponents = []
      user.eachOpposing { |b| user.pbAddTarget(targets,user,b,self,false) }
    end
  end

  def pbEffectGeneral(user)
    if @battle.field.disasters.length >= 3
      opponents = []
      user.eachOpposing do |b|
        opponents.push([b,b.index])
      end
      if @battle.pbSwapBattlers(opponents[0][1],opponents[1][1])
        @battle.pbDisplay(_INTL("{1} and {2} switched places!",
        opponents[0][0].pbThis,opponents[1][0].pbThis(true)))
        [opponents[0][1], opponents[1][1]].each { |idx| @battle.battlers[idx].pbEffectsOnEnteringPosition }
      end
    end
  end
end    



#===============================================================================
# Gains effects based on how many Disasters active. (Doomsfall)
#===============================================================================
class PokeBattle_Move_DH14 < PokeBattle_Move
  def recoilMove?; return @battle.field.disasters.length < 2; end  
  def highCriticalRate?;  return @battle.field.disasters.length >= 1; end
  def pbRecoilDamage(user,target); return (target.damageState.totalHPLost/4.0).round; end

  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
    return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    amt = pbRecoilDamage(user,target)
    amt = 1 if amt<1
    user.pbReduceHP(amt,false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end

  def pbEffectGeneral(user)
    return if @battle.field.disasters.length < 3
    user.pbOpposingSide.effects[PBEffects::StealthRock] = true
    @battle.pbDisplay(_INTL("Pointed stones float in the air around {1}!",
       user.pbOpposingTeam(true)))
  end

  def pbBaseDamage(baseDmg,user,target)
    if @battle.field.disasters.length >= 4
      baseDmg *= 2
    end
    return baseDmg
  end
end



#===============================================================================
# Gains effects based on how many Disasters active. (Blue Barrage)
#===============================================================================
class PokeBattle_Move_DH15 < PokeBattle_Move
  def pbPriority(user)
    ret = super
    ret += 1 if @battle.field.disasters.length >= 1
    return ret
  end
  
  def pbBaseAccuracy(user,target)
    return 100 if @battle.field.disasters.length >= 3
    return super
  end

  def pbEffectAfterAllHits(user,target)
    return if @battle.field.disasters.length < 2
    return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't knock off
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!",target.pbThis,itemName))
  end
  
  def pbEffectGeneral(user)
    if user.pbCanRaiseStatStage?(:ATTACK,user,self) && @battle.field.disasters.length >= 4
      user.pbRaiseStatStage(:ATTACK,2,user)
    end
  end
end



#===============================================================================
# Raises the user's Sp. Atk by 3 stages with a chance of paralyzing opponents.
# (Forbidden Cry)
#===============================================================================
class PokeBattle_Move_DH16 < PokeBattle_Move
  def pbEffectGeneral(user)
    user.pbRaiseStatStage(:SPECIAL_ATTACK,3,user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK)
    user.eachOpposing do |b|
      next if b.damageState.substitute
      b.pbParalyze(user) if b.pbCanParalyze?(user,false,self) && rand(100) <= 20
    end
  end
end


  
#===============================================================================
# Doubles in power if the target has a status condition. (Burial Ground)
#===============================================================================
class PokeBattle_Move_DH17 < PokeBattle_Move
  def pbBaseDamage(baseDmg,user,target)
    if target.poisoned? || target.burned? || target.asleep? || target.frozen? ||
      target.paralyzed? && (target.effects[PBEffects::Substitute]==0 || ignoresSubstitute?(user))
      baseDmg *= 2
    end
    return baseDmg
  end
end
  
  

#===============================================================================
# Deals 10% of the target's health as damage and makes it flinch.
# (Life Force Nuke)
#===============================================================================
class PokeBattle_Move_DH18 < PokeBattle_Move
  def recoilMove?;                 return true; end
  
  def pbEffectAgainstTarget(user,target)
    return if target.damageState.substitute
    target.pbFlinch(user)
  end
  
  def pbEffectAfterAllHits(user,target)
    return if target.damageState.unaffected
    return if !user.takesIndirectDamage?
    return if user.hasActiveAbility?(:ROCKHEAD)
    amt = (user.totalhp / 20.0).ceil
    amt = 1 if amt < 1
    user.pbReduceHP(amt,false)
    @battle.pbDisplay(_INTL("{1} is damaged by recoil!",user.pbThis))
    user.pbItemHPHealCheck
  end
end



#===============================================================================
# Sets up Aurora Veil in exchange for for some Evasion. (Phalanx Seal)
#===============================================================================
class PokeBattle_Move_DH19 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if !user.pbCanLowerStatStage?(:EVASION) || user.pbOwnSide.effects[PBEffects::AuroraVeil]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 7
    user.pbOwnSide.effects[PBEffects::AuroraVeil] = 11 if user.hasActiveItem?(:LIGHTCLAY)
    @battle.pbDisplay(_INTL("{1} made {2} stronger against physical and special moves!",
       @name,user.pbTeam(true)))
    user.pbLowerStatStage(:EVASION,2,user)
  end
end



#===============================================================================
# Traps the target, swapping its Atk. and Sp. Atk. stats. After 3 turns, deals
# damage to the target and releases it. (Devil's Room)
#===============================================================================
class PokeBattle_Move_DH20 < PokeBattle_Move_111
  def pbMoveFailed?(user,targets)
    return if targets.length > 1 || @battle.futureSight
    target = targets[0]
    return false if target.effects[PBEffects::DevilsRoom] == -1 && 
      target.effects[PBEffects::MeanLook] <= 0
    @battle.pbDisplay(_INTL("But it failed!"))
    return true    
  end
  
  def pbEffectAgainstTarget(user,target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::DevilsRoom]>0
    return if target.effects[PBEffects::MeanLook]>=0
    target.effects[PBEffects::MeanLook] = user.index
    # Set trapping effect duration and info, 3 to account for EoR
    target.effects[PBEffects::DevilsRoom] = 3
    @battle.pbDisplay(_INTL("{1} was trapped in the Devil's Room!",target.pbThis))
    target.attack,target.spatk = target.spatk,target.attack
    @battle.pbDisplay(_INTL("{1} had its Attack and Special Attack stats switched!",target.pbThis))
    effects = @battle.positions[target.index].effects
    effects[PBEffects::FutureSightMove]           = @id
    effects[PBEffects::FutureSightUserIndex]      = user.index
    effects[PBEffects::FutureSightUserPartyIndex] = user.pokemonIndex
    @battle.pbDisplay(_INTL("{1} will take massive damage after 2 turns!",target.pbThis))
  end
end


    
#===============================================================================
# Deals damage, then changes the user's type. (Tera Scramble)
#===============================================================================
class PokeBattle_Move_DH21 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    return if target.damageState.substitute
    newType = [
      :NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,:ROCK,:BUG,:GHOST,:STEEL,:FIRE,
      :WATER,:GRASS,:ELECTRIC,:PSYCHIC,:ICE,:DRAGON,:DARK,:FAIRY
    ].sample
    target.type1 = newType
    @battle.pbDisplay(_INTL("{1}'s primary type changed to {2}!",target.pbThis,newType.capitalize))
  end
  
  def pbAdditionalEffect(user,target)
    target.pbConfuse(user) if target.pbCanConfuse?(user)
  end
end



#===============================================================================
# Stops time for every Pokémon apart from the user. (Roar of Za Warudo's Time)
#===============================================================================
class PokeBattle_Move_DF00 < PokeBattle_Move
  def pbCanChooseMove?(user,commandPhase,showMessages)
    return true if @battle.field.effects[PBEffects::ZaWarudo] == 0
    if showMessages
      msg = _INTL("Can't stop time while it's already stopped!")
      (commandPhase) ? @battle.pbDisplayPaused(msg) : @battle.pbDisplay(msg)
    end
    return false
  end
  
  def pbEffectGeneral(user)
    user.effects[PBEffects::ZaWarudoUser] = true
    @battle.eachBattler do |b|
      b.effects[PBEffects::ZaWarudo] = 3
    end
    
    if @battle.field.effects[PBEffects::ZaWarudo] != 3
      @battle.field.effects[PBEffects::ZaWarudo] = 3
      $game_system.bgm_memorize()
      pbBGMFade(0.2)
      @battle.pbDisplay(_INTL("Time was stopped!"))
    end
  end
end



#===============================================================================
# Max out user's speed. (Heavenly Dash)
#===============================================================================
class PokeBattle_Move_DF01 < PokeBattle_StatUpMove
  def initialize(battle,move)
    super
    @statUp = [:SPEED,6]
  end
end



#===============================================================================
# Heal target back to full HP but lower all its stats by 2 stages.
# (Crazy Diamond)
#===============================================================================
class PokeBattle_Move_DF02 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,2,:DEFENSE,2,:SPECIAL_ATTACK,2,:SPECIAL_DEFENSE,2,
                 :SPEED,2,:ACCURACY,2,:EVASION,2]
  end
  
  def pbFailsAgainstTarget?(user,target)
    if target.hp == target.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",target.pbThis))
      return true
    end
    super
    return false
  end
  
  def pbEffectAgainstTarget(user,target)
    super
    target.pbRecoverHP(target.totalhp-target.hp)
  end
end



#===============================================================================
# Drop the target's Atk, Sp. Atk or Spd by 1 stage then apply a random status
# effect (that it isn't immune to). (Heaven's Door)
#===============================================================================
class PokeBattle_Move_DF03 < PokeBattle_Move
  def pbEffectAgainstTarget(user,target)
    stats = [:ATTACK, :SPECIAL_ATTACK, :SPEED]
    if !target.hasActiveAbility?([:CLEARBODY, :WHITESMOKE])
      stats.each do |stat|
        stats.delete(stat) if !target.pbCanLowerStatStage?(stat, user, self) && stats.length > 1
      end
    end
    target.pbLowerStatStage(stats.sample, 1, user)
    statuses = [:BURN, :POISON, :PARALYSIS, :SLEEP, :FROZEN]
    statuses.each do |status|
      statuses.delete(status) if !target.pbCanInflictStatus?(status, user, false, self) && statuses.length > 1
    end
    status = statuses.sample
    case status
    when :SLEEP     then target.pbSleep if target.pbCanSleep?(user,true,self)
    when :POISON    then target.pbPoison(user) if target.pbCanPoison?(user,true,self)
    when :BURN      then target.pbBurn(user) if target.pbCanBurn?(user,true,self)
    when :PARALYSIS then target.pbParalyze(user) if target.pbCanParalyze?(user,true,self)
    when :FROZEN    then target.pbFreeze if target.pbCanFreeze?(user,true,self)
    end
  end
end



#===============================================================================
# Use the target's highest stat against them. Also attack the target if they're
# about to switch out. (S. Heart Attack)
# Updated Battle_Phase_Attack to make it pursue the target
#===============================================================================
class PokeBattle_Move_DF04 < PokeBattle_Move
  def pbAccuracyCheck(user,target)
    return true if @battle.switching
    return super
  end
  
  def pbGetAttackStats(user,target)
    stats = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
    stat_nums = []
    stats.each do |stat|
      stat_nums.push(calcOppStat(target,stat))
    end
    max_stat = stat_nums.max
    stat = stats[stat_nums.index(max_stat)]
    return max_stat, target.stages[stat] + 6
  end
  
  def calcOppStat(target,stat)
    # get stat
    case stat
    when :ATTACK then stat_num = target.attack
    when :DEFENSE then stat_num = target.defense
    when :SPECIAL_ATTACK then stat_num = target.spatk
    when :SPECIAL_DEFENSE then stat_num = target.spdef
    when :SPEED then stat_num = target.speed
    end
    return stat_num if target.hasActiveAbility?(:UNAWARE) && @battle.moldBreaker
    # calculate the stat's effective number
    stageMul = [2,2,2,2,2,2, 2, 3,4,5,6,7,8]
    stageDiv = [8,7,6,5,4,3, 2, 2,2,2,2,2,2]
    statStage = target.stages[stat] + 6
    statStage = 6 if target.damageState.critical && statStage < 6
    stat_num = (stat_num.to_f*stageMul[statStage]/stageDiv[statStage]).floor
    return stat_num
  end
end



#===============================================================================
# Poison the target and set up 2 layers of Toxic Spikes. (Purple Haze)
#===============================================================================
class PokeBattle_Move_DF05 < PokeBattle_Move
  def pbEffectGeneral(user)
    return if user.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
    user.pbOpposingSide.effects[PBEffects::ToxicSpikes] += 2
    @battle.pbDisplay(_INTL("Poison spikes were scattered all around {1}'s feet!",
       user.pbOpposingTeam(true)))
  end

  def pbAdditionalEffect(user,target)
    target.pbPoison(user) if target.pbCanPoison?(user,false,self)
  end
end



#===============================================================================
# Poison and bind the target. (Metallica)
#===============================================================================
class PokeBattle_Move_DF06 < PokeBattle_Move_0CF
  def pbAdditionalEffect(user,target)
    target.pbPoison(user) if target.pbCanPoison?(user,false,self)
  end
end



#===============================================================================
# The raises all its stats by 1 stage, cure its status condition and gain
# immunity to them and negative stat changes, as well as improving its
# damage reduction against all types. (Love Train)
#===============================================================================
class PokeBattle_Move_DF07 < PokeBattle_MultiStatUpMove
  def initialize(battle,move)
    super
    @statUp = [:ATTACK,1,:DEFENSE,1,:SPECIAL_ATTACK,1,:SPECIAL_DEFENSE,1,
                :SPEED,1,:ACCURACY,1,:EVASION,1]
  end
  
  def pbEffectGeneral(user)
    super
    # cure status
    if [:BURN, :POISON, :PARALYSIS, :SLEEP, :FROZEN].include?(user.status)
      user.pbCureStatus
    end
    # gain immunity
    user.effects[PBEffects::LoveTrain] = 3
    @battle.pbDisplay(_INTL(
          "{1} became immune to status conditions and stat drops for 3 turns!",
          user.pbThis))
    # more resistant to all types
    return if user.effects[PBEffects::NormalResistance] >= 5
    user.effects[PBEffects::NormalResistance] += 1
    user.effects[PBEffects::WaterResistance] += 1
    user.effects[PBEffects::ElectricResistance] += 1
    user.effects[PBEffects::GrassResistance] += 1
    user.effects[PBEffects::IceResistance] += 1
    user.effects[PBEffects::FightingResistance] += 1
    user.effects[PBEffects::PoisonResistance] += 1
    user.effects[PBEffects::GroundResistance] += 1
    user.effects[PBEffects::FlyingResistance] += 1
    user.effects[PBEffects::PsychicResistance] += 1
    user.effects[PBEffects::BugResistance] += 1
    user.effects[PBEffects::RockResistance] += 1
    user.effects[PBEffects::DragonResistance] += 1
    user.effects[PBEffects::DarkResistance] += 1
    user.effects[PBEffects::SteelResistance] += 1
    user.effects[PBEffects::FairyResistance] += 1
    user.effects[PBEffects::FireResistance] += 1
    @battle.pbDisplay(_INTL("{1} became more resistant to all attacks!",user.pbThis))
  end
end



#===============================================================================
# 2 turn move. On the 2nd turn, attacks and ignores opponent's stat boosts.
# Ignores and destroys Reflect, Light Screen, Protect, etc.
#===============================================================================
class PokeBattle_Move_DF08 < PokeBattle_TwoTurnMove
  def pbChargingTurnMessage(user,targets)
    @battle.pbDisplay(_INTL("{1} began charging up its steel ball!",user.pbThis))
  end

  def pbAttackingTurnEffect(user,target)
    if target.selfProtected? && target.sideProtected?
      @battle.pbDisplay(_INTL("All protections on {1} and its side ended!", target.pbThis))
    elsif target.selfProtected?
      @battle.pbDisplay(_INTL("{1}'s protection ended!", target.pbThis))
    elsif target.sideProtected?
      @battle.pbDisplay(_INTL("All protections on {1}'s side ended!", target.pbThis))
    end
    target.effects[PBEffects::BanefulBunker]          = false
    target.effects[PBEffects::KingsShield]            = false
    target.effects[PBEffects::Protect]                = false
    target.effects[PBEffects::SpikyShield]            = false
    target.effects[PBEffects::Obstruct]               = false
    target.pbOwnSide.effects[PBEffects::CraftyShield] = false
    target.pbOwnSide.effects[PBEffects::MatBlock]     = false
    target.pbOwnSide.effects[PBEffects::QuickGuard]   = false
    target.pbOwnSide.effects[PBEffects::WideGuard]    = false
  end
end



#===============================================================================
# Lower target's Atk and Sp. Atk by 2 stages and increases the user's by the
# same amount. (Scary Monster)
#===============================================================================
class PokeBattle_Move_DF09 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:ATTACK,2,:SPECIAL_ATTACK,2]
  end
  
  def pbEffectAgainstTarget(user,target)
    super
    user.pbRaiseStatStage(:ATTACK,2,user) if user.pbCanRaiseStatStage?(:ATTACK,user,self)
    user.pbRaiseStatStage(:SPECIAL_ATTACK,2,user) if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
  end
end



#===============================================================================
# Bind and confuse target. (Fun fun fun)
#===============================================================================
class PokeBattle_Move_DF10 < PokeBattle_Move_0CF
  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    target.pbConfuse if target.pbCanConfuse?(user,false,self)
  end
end



#===============================================================================
# If target has an item, increase this move's power and remove the item. Steal
# the target's stat boosts before attacking. (Soft and Wet)
#===============================================================================
class PokeBattle_Move_DF11 < PokeBattle_Move_15D
  def pbBaseDamage(baseDmg,user,target)
    if target.item && !target.unlosableItem?(target.item)
       # NOTE: Damage is still boosted even if target has Sticky Hold or a
       #       substitute.
      baseDmg = (baseDmg*1.5).round
    end
    return baseDmg
  end

  def pbEffectAfterAllHits(user,target)
    return if @battle.wildBattle? && user.opposes?   # Wild Pokémon can't knock off
    return if user.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    return if !target.item || target.unlosableItem?(target.item)
    return if target.hasActiveAbility?(:STICKYHOLD) && !@battle.moldBreaker
    itemName = target.itemName
    target.pbRemoveItem(false)
    @battle.pbDisplay(_INTL("{1} dropped its {2}!",target.pbThis,itemName))
  end
end



#===============================================================================
# Lower target's Def and Sp. Def by 3 stages. (Vitamin C)
#===============================================================================
class PokeBattle_Move_DF12 < PokeBattle_TargetMultiStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:DEFENSE,3,:SPECIAL_DEFENSE,3]
  end
end



