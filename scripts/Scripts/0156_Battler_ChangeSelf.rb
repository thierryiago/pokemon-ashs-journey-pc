class PokeBattle_Battler
  #=============================================================================
  # Change HP
  #=============================================================================
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true)
    amt = amt.round
    amt = @hp if amt>@hp
    amt = 1 if amt<1 && !fainted?
    oldHP = @hp
    self.hp -= amt
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    @tookDamage = true if amt>0 && registerDamage
    return amt
  end

  def pbRecoverHP(amt,anim=true,anyAnim=true)
    amt = amt.round
    amt = @totalhp-@hp if amt>@totalhp-@hp
    amt = 1 if amt<1 && @hp<@totalhp
    oldHP = @hp
    self.hp += amt
    PBDebug.log("[HP change] #{pbThis} gained #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    self.damage_done = 0
    return amt
  end

  def pbRecoverHPFromDrain(amt,target,msg=nil)
    if target.hasActiveAbility?(:LIQUIDOOZE)
      @battle.pbShowAbilitySplash(target)
      pbReduceHP(amt)
      @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",pbThis))
      @battle.pbHideAbilitySplash(target)
      pbItemHPHealCheck
    else
      msg = _INTL("{1} had its energy drained!",target.pbThis) if nil_or_empty?(msg)
      @battle.pbDisplay(msg)
      if canHeal?
        amt = (amt*1.3).floor if hasActiveItem?(:BIGROOT)
        pbRecoverHP(amt)
      end
    end
  end

  def pbFaint(showMessage=true)
    if !fainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return
    end
    return if @fainted   # Has already fainted properly
    @battle.pbDisplayBrief(_INTL("{1} fainted!",pbThis)) if showMessage
    PBDebug.log("[Pokémon fainted] #{pbThis} (#{@index})") if !showMessage
    @battle.scene.pbFaintBattler(self)
    pbInitEffects(false)
    # Reset status
    self.status      = :NONE
    self.statusCount = 0
    # Lose happiness
    if @pokemon && @battle.internalBattle
      badLoss = false
      @battle.eachOtherSideBattler(@index) do |b|
        badLoss = true if b.level>=self.level+30
      end
      @pokemon.changeHappiness((badLoss) ? "faintbad" : "faint")
    end
    # Reset form
    @battle.peer.pbOnLeavingBattle(@battle,@pokemon,@battle.usedInBattle[idxOwnSide][@index/2])
    @pokemon.makeUnmega if mega?
    @pokemon.makeUnprimal if primal?
    self.damage_done = 0 # Yamask
    # Do other things
    @battle.pbClearChoice(@index)   # Reset choice
    pbOwnSide.effects[PBEffects::LastRoundFainted] = @battle.turnCount
    # Check other battlers' abilities that trigger upon a battler fainting
    pbAbilitiesOnFainting
    # Check for end of primordial weather
    @battle.pbEndPrimordialWeather
    @battle.pbEndDisasters # End disasters for Despair Challenge
    @battle.pbSetBattled(self)
  end

  #=============================================================================
  # Move PP
  #=============================================================================
  def pbSetPP(move,pp)
    move.pp = pp
    # No need to care about @effects[PBEffects::Mimic], since Mimic can't copy
    # Mimic
    if move.realMove && move.id == move.realMove.id && !@effects[PBEffects::Transform]
      move.realMove.pp = pp
    elsif move.realMove
      mult = move.realMove.total_pp/move.total_pp
      move.realMove.pp = pp * mult
    end
  end

  def pbReducePP(move)
    return true if usingMultiTurnAttack?
    return true if move.pp<0          # Don't reduce PP for special calls of moves
    return true if move.total_pp<=0   # Infinite PP, can always be used
    return false if move.pp==0        # Ran out of PP, couldn't reduce
    pbSetPP(move,move.pp-1) if move.pp>0
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end

  #=============================================================================
  # Change type
  #=============================================================================
  def pbChangeTypes(newType)
    if newType.is_a?(PokeBattle_Battler)
      newTypes = newType.pbTypes
      newTypes.push(:NORMAL) if newTypes.length == 0
      newType3 = newType.effects[PBEffects::Type3]
      newType3 = nil if newTypes.include?(newType3)
      @type1 = newTypes[0]
      @type2 = (newTypes.length == 1) ? newTypes[0] : newTypes[1]
      @effects[PBEffects::Type3] = newType3
    elsif newType.is_a?(Array)
      newType3 = newType[2] || nil
      @type1 = newType[0]
      @type2 = newType[1] || newType[0]
      @effects[PBEffects::Type3] = newType3
    else
      newType = GameData::Type.get(newType).id
      @type1 = newType
      @type2 = newType
      @effects[PBEffects::Type3] = nil
    end
    @effects[PBEffects::BurnUp] = false
    @effects[PBEffects::Roost]  = false
  end

  #=============================================================================
  # Forms
  #=============================================================================
  def pbChangeForm(newForm,msg)
    return if fainted? || @effects[PBEffects::Transform] || @form==newForm
    oldForm = @form
    oldDmg = @totalhp-@hp
    self.form = newForm
    pbUpdate(true)
    @hp = @totalhp-oldDmg
    @effects[PBEffects::WeightChange] = 0 if Settings::MECHANICS_GENERATION >= 6
    @battle.scene.pbChangePokemon(self,@pokemon)
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(msg) if msg && msg!=""
    PBDebug.log("[Form changed] #{pbThis} changed from form #{oldForm} to form #{newForm}")
    @battle.pbSetSeen(self)
  end

  def pbCheckFormOnStatusChange
    return if fainted? || @effects[PBEffects::Transform]
    # Shaymin - reverts if frozen
    if isSpecies?(:SHAYMIN) && frozen?
      pbChangeForm(0,_INTL("{1} transformed!",pbThis))
    end
  end

  def pbCheckFormOnMovesetChange
    return if fainted? || @effects[PBEffects::Transform]
    # Keldeo - knowing Secret Sword
    if isSpecies?(:KELDEO)
      newForm = 0
      newForm = 1 if pbHasMove?(:SECRETSWORD)
      pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
    end
  end

  def pbCheckFormOnWeatherChange
    return if fainted? || @effects[PBEffects::Transform]
    # Castform - Forecast
    if isSpecies?(:CASTFORM)
      if hasActiveAbility?(:FORECAST)
        newForm = 0
        case @battle.pbWeather
        when :Sun, :HarshSun   then newForm = 1
        when :Rain, :HeavyRain then newForm = 2
        when :Hail             then newForm = 3
        end
        newForm = 0 if hasUtilityUmbrella? && [1,2].include?(newForm)
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Cherrim - Flower Gift
    if isSpecies?(:CHERRIM)
      if hasActiveAbility?(:FLOWERGIFT)
        newForm = 0
        newForm = 1 if [:Sun, :HarshSun].include?(@battle.pbWeather)
        newForm = 0 if hasUtilityUmbrella?
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} transformed!",pbThis))
        end
      else
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
      end
    end
    # Eiscue - Ice Face
    if isSpecies?(:EISCUE) && self.ability == :ICEFACE && @battle.pbWeather == :Hail
      if @form == 1
        @battle.pbShowAbilitySplash(self,true)
        pbChangeForm(0,_INTL("{1} transformed!",pbThis))
        @battle.pbHideAbilitySplash(self)
      end
    end
  end

  def pbCheckFormOnTerrainChange
    return if fainted?
    if hasActiveAbility?(:MIMICRY)
      newTypes = self.pbTypes
      originalTypes = [@pokemon.type1,@pokemon.type2] | []
      case @battle.field.terrain
      when :Electric   then newTypes = :ELECTRIC
      when :Grassy     then newTypes = :GRASS
      when :Misty      then newTypes = :FAIRY
      when :Psychic    then newTypes = :PSYCHIC
      else;                 newTypes = originalTypes.dup
      end
      if self.pbTypes != newTypes
        pbChangeTypes(newTypes)
        @battle.pbShowAbilitySplash(self,true)
        if newTypes != originalTypes
          if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
            @battle.pbDisplay(_INTL("{1}'s type changed to {3}!",pbThis,
             self.abilityName,GameData::Type.get(newTypes).name))
          else
            @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",pbThis,
             self.abilityName,GameData::Type.get(newTypes).name))
          end
        else
          @battle.pbDisplay(_INTL("{1} returned back to normal!",pbThis))
        end
        @battle.pbHideAbilitySplash(self)
      end
    end
  end

  # Checks the Pokémon's form and updates it if necessary. Used for when a
  # Pokémon enters battle (endOfRound=false) and at the end of each round
  # (endOfRound=true).
  def pbCheckForm(endOfRound=false)
    return if fainted? || @effects[PBEffects::Transform]
    # Form changes upon entering battle and when the weather changes
    pbCheckFormOnWeatherChange if !endOfRound
    # Form changes upon entering battle and when the terrain changes
    pbCheckFormOnTerrainChange if !endOfRound
    # Darmanitan - Zen Mode
    if isSpecies?(:DARMANITAN) && self.ability == :ZENMODE
      oldform = self.form
      if @hp <= @totalhp/2
        self.form=2 if self.form==0; self.form=3 if self.form==1
      else
        self.form=0 if self.form==2; self.form=1 if self.form==3
      end
      if self.form != oldform
        transformed = true
      end
    end
    if transformed
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL("{1} transformed!",pbThis))
      PBDebug.log("[Form changed] #{pbThis} changed to form #{self.form}")
    end
    # Minior - Shields Down
    if isSpecies?(:MINIOR) && self.ability == :SHIELDSDOWN
      if @hp>@totalhp/2   # Turn into Meteor form
        newForm = (@form>=7) ? @form-7 : @form
        if @form!=newForm
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(newForm,_INTL("{1} deactivated!",abilityName))
        elsif !endOfRound
          @battle.pbDisplay(_INTL("{1} deactivated!",abilityName))
        end
      elsif @form<7   # Turn into Core form
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(@form+7,_INTL("{1} activated!",abilityName))
      end
    end
    # Wishiwashi - Schooling
    if isSpecies?(:WISHIWASHI) && self.ability == :SCHOOLING
      if @level>=20 && @hp>@totalhp/4
        if @form!=1
          @battle.pbShowAbilitySplash(self,true)
          @battle.pbHideAbilitySplash(self)
          pbChangeForm(1,_INTL("{1} formed a school!",pbThis))
        end
      elsif @form!=0
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(0,_INTL("{1} stopped schooling!",pbThis))
      end
    end
    # Zygarde - Power Construct
    if isSpecies?(:ZYGARDE) && self.ability == :POWERCONSTRUCT && endOfRound
      if @hp<=@totalhp/2 && @form<2   # Turn into Complete Forme
        newForm = @form+2
        @battle.pbDisplay(_INTL("You sense the presence of many!"))
        @battle.pbShowAbilitySplash(self,true)
        @battle.pbHideAbilitySplash(self)
        pbChangeForm(newForm,_INTL("{1} transformed into its Complete Forme!",pbThis))
      end
    end
    # Moltres - Awaken
    if isSpecies?(:MOLTRES) && @form == 2 && self.ability == :AWAKEN
      if @hp < @totalhp*0.75
        @battle.pbShowAbilitySplash(self,true)
        pbChangeForm(0,_INTL("{1} grows out of its Sphere Mode!",pbThis))
        @battle.pbHideAbilitySplash(self)
        self.moves = []
        attackMoves = [Pokemon::Move.new(:HEATWAVE),Pokemon::Move.new(:RECOVER),Pokemon::Move.new(:AEROBLAST),Pokemon::Move.new(:PROTECT)]
        for i in 0...4
          self.moves[i] = attackMoves[i]
          self.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
        end
        @battle.pbDisplay(_INTL("{1} changed its moves!",pbThis))
        self.ability = :PRESSURE
        self.passive = :PHOENIXREVIVAL
        BattleHandlers.triggerAbilityOnSwitchIn(:PRESSURE,self,@battle)
      end
    end
    # Moltres - Phoenix Revival
    if isSpecies?(:MOLTRES) && @form == 0 && self.passive == :PHOENIXREVIVAL
      if @hp == 1
        @battle.pbShowAbilitySplash(self,true)
        pbChangeForm(3,_INTL("{1} decided to go all in!",pbThis))
        @battle.pbDisplay(_INTL("{1} turned into an Immortal Phoenix!",pbThis))
        pbRaiseStatStageByAbility(:SPECIAL_ATTACK,1,self)
        @battle.pbHideAbilitySplash(self)
        pbRecoverHP(@totalhp-@hp)
        self.moves = []
        attackMoves = [Pokemon::Move.new(:BLASTBURN),Pokemon::Move.new(:AEROBLAST)]
        for i in 0...2
          self.moves[i] = attackMoves[i]
          self.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
        end
        @battle.pbDisplay(_INTL("{1} changed its moves again!",pbThis))
        self.passive = :EXTENDRANGE
      end
    end
    # Palkia - King of Space
    if isSpecies?(:PALKIA) && @form == 0 && self.ability == :KINGOFSPACE
      if @hp <= @totalhp/2
        playerName = @battle.player[0].name
        @battle.pbDisplay(_INTL("{1}: Stand proud {2}. You're strong.",name,playerName))
        @battle.pbDisplay(_INTL("{1}: What... is this?",playerName))
        @battle.pbDisplay(_INTL("{1}: As a reward, I will unleash my full power.",name))
        pbBGMFade(0.2)
        $game_system.bgm_play_internal(pbResolveAudioFile("SPECIALZ"),0)
        pbChangeForm(1,_INTL(
          "{1} formed infinite space around itself, nullifying all non-critical damage!",
          pbThis))
        self.ability = :INFINITESPACE
        @battle.pbShowAbilitySplash(self,true)
        battle.pbDisplay(_INTL("{1} opened its domain, Infinite Void!",pbThis))
        pbRaiseStatStageByAbility(:SPEED,1,self)
        @battle.pbHideAbilitySplash(self)
        pbRecoverHP(@totalhp-@hp)
        self.moves = []
        attackMoves = [Pokemon::Move.new(:BSPACIALREND),Pokemon::Move.new(:HYDROPUMP)]
        for i in 0...2
          self.moves[i] = attackMoves[i]
          self.moves[i] = PokeBattle_Move.from_pokemon_move(@battle,attackMoves[i])
        end
        @battle.pbDisplay(_INTL("{1} changed its moves!",pbThis))
      end
    end
  end

  def pbTransform(target)
    oldAbil = @ability_id
    @effects[PBEffects::Transform]        = true
    @effects[PBEffects::TransformSpecies] = target.species
    pbChangeTypes(target)
    self.ability = target.ability
    @attack  = target.attack
    @defense = target.defense
    @spatk   = target.spatk
    @spdef   = target.spdef
    @speed   = target.speed
    GameData::Stat.each_battle { |s| @stages[s.id] = target.stages[s.id] }
    if Settings::NEW_CRITICAL_HIT_RATE_MECHANICS
      @effects[PBEffects::FocusEnergy] = target.effects[PBEffects::FocusEnergy]
      @effects[PBEffects::LaserFocus]  = target.effects[PBEffects::LaserFocus]
    end
    @moves.clear
    target.moves.each_with_index do |m,i|
      @moves[i] = PokeBattle_Move.from_pokemon_move(@battle, Pokemon::Move.new(m.id))
      @moves[i].pp       = 5
      @moves[i].total_pp = 5
    end
    @effects[PBEffects::Disable]      = 0
    @effects[PBEffects::DisableMove]  = nil
    @effects[PBEffects::WeightChange] = target.effects[PBEffects::WeightChange]
    @battle.scene.pbRefreshOne(@index)
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,target.pbThis(true)))
    pbOnAbilityChanged(oldAbil)
  end

  def pbHyperMode; end
end
