class PokeBattle_AI
  #=============================================================================
  # Get a score for the given move based on its effect
  #=============================================================================
  alias improvedAI_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode

  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    #---------------------------------------------------------------------------
    when "103"
      if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3 && move.statusMove?
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) } && move.statusMove?
        score -= 90   # Opponent can't switch in any Pokemon
      elsif user.pbOpposingSide.effects[PBEffects::Spikes] < 3
        score += 15 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [40, 32, 24][user.pbOpposingSide.effects[PBEffects::Spikes]]
      end
    #---------------------------------------------------------------------------
    when "104"
      if user.pbOpposingSide.effects[PBEffects::ToxicSpikes] >= 2
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90  # Opponent can't switch in any Pokemon
      else
        score += 10 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [26, 13][user.pbOpposingSide.effects[PBEffects::ToxicSpikes]]
      end
    #---------------------------------------------------------------------------
    when "105"
      if user.pbOpposingSide.effects[PBEffects::StealthRock] && move.statusMove?
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) } && move.statusMove?
        score -= 90   # Opponent can't switch in any Pokemon
      elsif !user.pbOpposingSide.effects[PBEffects::StealthRock]
        score += 25 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      end
    #---------------------------------------------------------------------------
    when "153"
      if user.pbOpposingSide.effects[PBEffects::StickyWeb]
        score -= 95
      else
        score += 15 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      end
    #---------------------------------------------------------------------------
    when "0FF"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Sun
        score -= 90
      else
        user.eachMove do |m|
          score += 20 if m.damagingMove? && m.type == :FIRE
          score += 40 if m.function == "0C4"
        end
        
        score += 40 if user.item == :HEATROCK
        score += 40 if user.ability == :CHLOROPHYLL || user.ability == :FLOWERGIFT || user.ability == :SOLARPOWER
        score += 10 if user.ability == :LEAFGUARD
        score -= 20 if user.ability == :DRYSKIN
      end
    #---------------------------------------------------------------------------
    when "100"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Rain
        score -= 90
      else
        user.eachMove do |m|
          score += 20 if m.damagingMove? && m.type == :WATER
          score += 25 if m.function == "008" || m.function == "015"
        end
        
        score += 40 if user.item == :DAMPROCK
        score += 40 if user.ability == :SWIFTSWIM
        score += 20 if user.ability == :WATERDISH || user.ability == :DRYSKIN
        score += 10 if user.ability == :HYDRATION
      end
    #---------------------------------------------------------------------------
    when "101"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Sandstorm
        score -= 90
      else
        if user.pbHasType?(:ROCK) && skill >= PBTrainerAI.highSkill
          score += 40
        elsif user.pbHasType?(:STEEL) || user.pbHasType?(:GROUND) || user.pbHasType?(:ROCK)
          score += 15
        elsif user.ability != :SANDRUSH && user.ability != :SANDFORCE && user.ability != :SANDVEIL
          score -= 90
        end
        
        score += 40 if user.item == :SMOOTHROCK
        score += 40 if user.ability == :SANDRUSH || user.ability == :SANDFORCE
        score += 20 if user.ability == :SANDVEIL
      end
    #---------------------------------------------------------------------------
    when "102"
      if @battle.pbCheckGlobalAbility(:AIRLOCK) ||
         @battle.pbCheckGlobalAbility(:CLOUDNINE)
        score -= 90
      elsif @battle.field.weather == :Hail
        score -= 90
      else
        user.eachMove do |m|
          score += 30 if m.function == "00D" || m.function == "167"
        end
        
        if user.pbHasType?(:ICE)
          score += 15
        elsif user.ability != :SLUSHRUSH && user.ability != :ICEBODY && user.ability != :SNOWCLOAK
          score -= 90
        end
        
        score += 40 if user.item == :ICYROCK
        score += 40 if user.ability == :SLUSHRUSH
        score += 20 if user.ability == :ICEBODY || user.ability == :SNOWCLOAK
      end
    #---------------------------------------------------------------------------
    when "0A2"
    if user.pbOwnSide.effects[PBEffects::Reflect] > 0
      score -= 90
    elsif user.item == :LIGHTCLAY
      score += 320
    end
    #---------------------------------------------------------------------------
    when "0A3"
    if user.pbOwnSide.effects[PBEffects::LightScreen] > 0
      score -= 90
    elsif user.item == :LIGHTCLAY
      score += 340
    end
    #---------------------------------------------------------------------------
    when "167"
      if user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0 || @battle.field.weather != :Hail
        score -= 90
      elsif user.item == :LIGHTCLAY
        score += 90
      else
        score += 40
      end
    #---------------------------------------------------------------------------
    when "154"
        if @battle.field.terrain == :Electric
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    when "155"
        if @battle.field.terrain == :Grassy
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    when "156"
        if @battle.field.terrain == :Misty
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    when "173"
        if @battle.field.terrain == :Psychic
          score -= 90
        elsif user.item == :TERRAINEXTENDER
          score += 50
        end
    #---------------------------------------------------------------------------
    else
      return improvedAI_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end