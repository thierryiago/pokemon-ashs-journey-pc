class PokeBattle_Battle
  #=============================================================================
  # Using a field effect (added by: Luc-ker)
  #=============================================================================
  def pbRegisterFieldUse(idxBattler)
    @choices[idxBattler][0] = :Field
    @choices[idxBattler][1] = 0
    @choices[idxBattler][2] = nil
    return true
  end

  def pbUseFieldEffect(idxBattler)
    battler = @battlers[idxBattler]
    case fieldEffect
    when :None
      # Not likely to happen as this menu should only show up if there's a field
      # effect, but just in case.
      pbDisplayPaused(_INTL("There's no field effect to use!"))
    when :Electric
      command = pbShowCommands("Select an effect to use.",
        ["Enable/Disable Zap Field", "Charge"], -1)
      case command
      when 0
        if @field.effects[PBEffects::FieldOn]
          pbDisplay(_INTL("The Zap Field was turned off!"))
        else
          pbDisplay(_INTL("The Zap Field was turned on!"))
        end
        @field.effects[PBEffects::FieldOn] = !@field.effects[PBEffects::FieldOn]
      when 1
        battler.pbUseMoveSimple(:CHARGE)
      end
    when :Psychic
      command = pbShowCommands("Select an effect to use.",
        ["Teleport", "Trick Room", "Reflect", "Light Screen"], -1)
      case command
      when 0
        battler.pbUseMoveSimple(:TELEPORT)
        newBattler = @battlers[idxBattler]
        if newBattler.pbCanRaiseStatStage?(:EVASION)
          newBattler.pbRaiseStatStage(:EVASION, 1, battler)
        end
      when 1
        battler.pbUseMoveSimple(:TRICKROOM)
        if battler.pbCanLowerStatStage?(:SPEED)
          battler.pbLowerStatStage(:SPEED, 1, battler)
        end
        battler.eachAlly do |b|
          next if !b.pbCanLowerStatStage?(:SPEED)
          b.pbLowerStatStage(:SPEED, 1, battler)
        end
      when 2
        battler.pbUseMoveSimple(:REFLECT)
        if battler.pbCanRaiseStatStage?(:DEFENSE)
          battler.pbRaiseStatStage(:DEFENSE, 1, battler)
        end
        battler.eachAlly do |b|
          next if !b.pbCanRaiseStatStage?(:DEFENSE)
          b.pbRaiseStatStage(:DEFENSE, 1, battler)
        end
      when 3
        battler.pbUseMoveSimple(:LIGHTSCREEN)
        if battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE)
          battler.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
        end
        battler.eachAlly do |b|
          next if !b.pbCanRaiseStatStage?(:SPECIAL_DEFENSE)
          b.pbRaiseStatStage(:SPECIAL_DEFENSE, 1, battler)
        end
      end
    when :Grass
      command = pbShowCommands("Select an effect to use.",
        ["Enable/Disable Vine Field", "Sunny Day", "Rain Dance"], -1)
      case command
      when 0
        if @field.effects[PBEffects::FieldOn]
          pbDisplay(_INTL("The Vine Field was turned off!"))
        else
          pbDisplay(_INTL("The Vine Field was turned on!"))
        end
        @field.effects[PBEffects::FieldOn] = !@field.effects[PBEffects::FieldOn]
      when 1
        battler.pbUseMoveSimple(:SUNNYDAY)
      when 2
        battler.pbUseMoveSimple(:RAINDANCE)
      end
    when :Mist
      command = pbShowCommands("Select an effect to use.",
        ["Mist", "Geomancy"], -1)
      case command
      when 0
        battler.pbUseMoveSimple(:MIST)
      when 1
        battler.pbUseMoveSimple(:GEOMANCY)
      end
    when :Fire
      command = pbShowCommands("Select an effect to use.",
        ["Enable/Disable Burn Field", "Fire Spin"], -1)
      case command
      when 0
        if @field.effects[PBEffects::FieldOn]
          pbDisplay(_INTL("The Burn Field was turned off!"))
        else
          pbDisplay(_INTL("The Burn Field was turned on!"))
        end
        @field.effects[PBEffects::FieldOn] = !@field.effects[PBEffects::FieldOn]
      when 1
        battler.pbUseMoveSimple(:FIRESPIN)
      end
    when :Water
      command = pbShowCommands("Select an effect to use.",
        ["Enable/Disable Soak Field", "Whirlpool"], -1)
      case command
      when 0
        if @field.effects[PBEffects::FieldOn]
          pbDisplay(_INTL("The Soak Field was turned off!"))
        else
          pbDisplay(_INTL("The Soak Field was turned on!"))
        end
        @field.effects[PBEffects::FieldOn] = !@field.effects[PBEffects::FieldOn]
      when 1
        battler.pbUseMoveSimple(:WHIRLPOOL)
      end
    when :Rock
      command = pbShowCommands("Select an effect to use.",
        ["Enable/Disable Sand Field", "Stealth Rock", "Spikes", "Rapid Spin"], -1)
      case command
      when 0
        if @field.effects[PBEffects::FieldOn]
          pbDisplay(_INTL("The Sand Field was turned off!"))
        else
          pbDisplay(_INTL("The Sand Field was turned on!"))
        end
        @field.effects[PBEffects::FieldOn] = !@field.effects[PBEffects::FieldOn]
      when 1
        battler.pbUseMoveSimple(:STEALTHROCK)
        if battler.pbCanRaiseStatStage?(:ATTACK)
          battler.pbRaiseStatStage(:ATTACK, 1, battler)
        end
        battler.eachAlly do |b|
          next if !b.pbCanRaiseStatStage?(:SPEED)
          b.pbRaiseStatStage(:ATTACK, 1, battler)
        end
      when 2
        battler.pbUseMoveSimple(:SPIKES)
        if battler.pbCanRaiseStatStage?(:DEFENSE)
          battler.pbRaiseStatStage(:DEFENSE, 1, battler)
        end
        battler.eachAlly do |b|
          next if !b.pbCanRaiseStatStage?(:DEFENSE)
          b.pbRaiseStatStage(:DEFENSE, 1, battler)
        end
      when 3
        battler.pbUseMoveSimple(:RAPIDSPIN)
        if battler.pbCanRaiseStatStage?(:SPEED)
          battler.pbRaiseStatStage(:SPEED, 1, battler)
        end
        battler.eachAlly do |b|
          next if !b.pbCanRaiseStatStage?(:SPEED)
          b.pbRaiseStatStage(:SPEED, 1, battler)
        end
      end
    when :Ice
      command = pbShowCommands("Select an effect to use.",
        ["Enable/Disable Blizzard Field", "Aurora Veil", "Haze"], -1)
      case command
      when 0
        if @field.effects[PBEffects::FieldOn]
          pbDisplay(_INTL("The Blizzard Field was turned off!"))
        else
          pbDisplay(_INTL("The Blizzard Field was turned on!"))
        end
        @field.effects[PBEffects::FieldOn] = !@field.effects[PBEffects::FieldOn]
      when 1
        battler.pbUseMoveSimple(:AURORAVEIL)
      when 2
        battler.pbUseMoveSimple(:HAZE)
      end
    end
  end
  
  def pbUpdateBackdropSprites(backdropName)
    self.backdrop = backdropName
    # Need to dispose sprites first - I've noticed that
    # this causes issues when the battle ends otherwise
    @scene.sprites["battle_bg"].dispose
    @scene.sprites["battle_bg2"].dispose
    for side in 0...2
      @scene.sprites["base_#{side}"].dispose
    end
    @scene.sprites["cmdBar_bg"].dispose
    @scene.pbCreateBackdropSprites
  end
end
