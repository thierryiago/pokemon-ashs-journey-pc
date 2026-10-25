#===============================================================================
#
#===============================================================================
class EnemyBuffs
  attr_accessor :attackBuff
  attr_accessor :defenseBuff
  attr_accessor :spattackBuff
  attr_accessor :spdefenseBuff
  attr_accessor :speedBuff
  attr_accessor :accuracyBuff
  attr_accessor :evasionBuff
  attr_accessor :statusImmunity
  attr_accessor :interfereImmunity
  attr_accessor :vigilance

  def initialize
    @attackBuff         = 0     # Attack gained by enemy when entering battle
    @defenseBuff        = 0     # Defense gained by enemy when entering battle
    @spattackBuff       = 0     # Sp. Attack gained by enemy when entering battle
    @spdefenseBuff      = 0     # Sp. Defense gained by enemy when entering battle
    @speedBuff          = 0     # Speed gained by enemy when entering battle
    @accuracyBuff       = 0     # Accuracy gained by enemy when entering battle
    @evasionBuff        = 0     # Evasion gained by enemy when entering battle
    @statusImmunity     = 0     # Enemy immune to status conditions
    @interfereImmunity  = 0     # Enemy immune to flinch, trap and confusion
    @vigilance          = 0     # Enemy immune to crits
  end
  
  def getStatBuff(stat)
    case stat
    when :ATTACK
      return attackBuff
    when :DEFENSE
      return defenseBuff
    when :SPECIAL_ATTACK
      return spattackBuff
    when :SPECIAL_DEFENSE
      return spdefenseBuff
    when :SPEED
      return speedBuff
    when :ACCURACY
      return accuracyBuff
    when :EVASION
      return evasionBuff
    end
    return 0
  end
  
  def includeStatusImmunity?
    return statusImmunity == 1
  end
  
  def includeInterferenceImmunity?
    return interfereImmunity == 1
  end
  
  def includeVigilance?
    return vigilance == 1
  end
  
  def getCreditMultiplier
    mult = 1
    GameData::Stat.each_battle do |s|
      statMult = [:SPEED, :EVASION].include?(s.id) ? 0.2 : 0.1
      mult += statMult * getStatBuff(s.id)
    end
    mult += 0.15 * statusImmunity
    mult += 0.15 * interfereImmunity
    mult += 0.15 * vigilance
    return mult.round(2)
  end
end

#===============================================================================
# Options main screen
#===============================================================================
class EnemyBuffs_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(inloadscreen=false)
    @sprites = {}
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    varNum = 50
    if $game_switches[694]
      chall = "Sync Challenge"
    elsif $game_switches[693]
      chall = "Titan Challenge"
      varNum = 49
    else
      chall = "???"
    end
    @sprites["title"] = Window_UnformattedTextPokemon.newWithSize(
       _INTL("Enemy Buffs ({1})", chall),0,0,Graphics.width,64,@viewport)
    enemyBuffs = pbGet(varNum)
    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].text           = _INTL("Press Enter for more details.")
    @sprites["textbox"].letterbyletter = false
    pbSetSystemFont(@sprites["textbox"].contents)
    # Enemy Buffs
    @BuffOptions = [
       SliderOption.new(_INTL("Attack Buff"),0,6,1,
         proc { enemyBuffs.attackBuff },
         proc { |value| enemyBuffs.attackBuff = value }
       ),
       SliderOption.new(_INTL("Defense Buff"),0,6,1,
         proc { enemyBuffs.defenseBuff },
         proc { |value| enemyBuffs.defenseBuff = value }
       ),
       SliderOption.new(_INTL("Sp. Attack Buff"),0,6,1,
         proc { enemyBuffs.spattackBuff },
         proc { |value| enemyBuffs.spattackBuff = value }
       ),
       SliderOption.new(_INTL("Sp. Defense Buff"),0,6,1,
         proc { enemyBuffs.spdefenseBuff },
         proc { |value| enemyBuffs.spdefenseBuff = value }
       ),
       SliderOption.new(_INTL("Speed Buff"),0,6,1,
         proc { enemyBuffs.speedBuff },
         proc { |value| enemyBuffs.speedBuff = value }
       ),
       SliderOption.new(_INTL("Accuracy Buff"),0,6,1,
         proc { enemyBuffs.accuracyBuff },
         proc { |value| enemyBuffs.accuracyBuff = value }
       ),
       SliderOption.new(_INTL("Evasion Buff"),0,6,1,
         proc { enemyBuffs.evasionBuff },
         proc { |value| enemyBuffs.evasionBuff = value }
       ),
       EnumOption.new(_INTL("Vigilance"),[_INTL("Off"),_INTL("On")],
        proc { enemyBuffs.vigilance },
        proc { |value| enemyBuffs.vigilance = value }
       )
    ]
    buffs2 = [  # Titan Challenge already has these buffs built in
       EnumOption.new(_INTL("Status Immunity"),[_INTL("Off"),_INTL("On")],
        proc { enemyBuffs.statusImmunity },
        proc { |value| enemyBuffs.statusImmunity = value }
       ),
       EnumOption.new(_INTL("Interference Immunity"),[_INTL("Off"),_INTL("On")],
        proc { enemyBuffs.interfereImmunity },
        proc { |value| enemyBuffs.interfereImmunity = value }
       )
    ]
    if $game_switches[694]  # Sync Challenge
      @BuffOptions = @BuffOptions + buffs2
    end
    @BuffOptions = pbAddOnOptions(@BuffOptions)
    @sprites["option"] = Window_PokemonOption.new(@BuffOptions,0,
       @sprites["title"].height,Graphics.width,
       Graphics.height-@sprites["title"].height-@sprites["textbox"].height)
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = true
    # Get the values of each option
    for i in 0...@BuffOptions.length
      @sprites["option"].setValueNoRefresh(i,(@BuffOptions[i].get || 0))
    end
    @sprites["option"].refresh
    pbDeactivateWindows(@sprites)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbAddOnOptions(options)
    return options
  end

  def pbOptions
    oldSystemSkin = $PokemonSystem.frame      # Menu
    oldTextSkin   = $PokemonSystem.textskin   # Speech
    pbActivateWindow(@sprites,"option") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
          @sprites["textbox"].text = _INTL("Press Enter for more details.")
        elsif Input.trigger?(Input::USE)
          break if @sprites["option"].index==@BuffOptions.length
          showBuffDescription(@BuffOptions[@sprites["option"].index].name)
        end
      end
    }
  end
  
  def showBuffDescription(buffName)
    case buffName
    when "Attack Buff"
      desc = "Enemy Pokémon gain +(number) Attack when entering battle. Credit mult +0.1."
    when "Defense Buff"
      desc = "Enemy Pokémon gain +(number) Defense when entering battle. Credit mult +0.1."
    when "Sp. Attack Buff"
      desc = "Enemy Pokémon gain +(number) Sp. Attack when entering battle. Credit mult +0.1."
    when "Sp. Defense Buff"
      desc = "Enemy Pokémon gain +(number) Sp. Def. when entering battle. Credit mult +0.1."
    when "Speed Buff"
      desc = "Enemy Pokémon gain +(number) Speed when entering battle. Credit mult +0.2."
    when "Accuracy Buff"
      desc = "Enemy Pokémon gain +(number) Accuracy when entering battle. Credit mult +0.05."
    when "Evasion Buff"
      desc = "Enemy Pokémon gain +(number) Evasion when entering battle. Credit mult +0.2."
    when "Status Immunity"
      desc = "Enemy Pokémon are immune to status conditions. Credit mult +0.15."
    when "Interference Immunity"
      desc = "Enemy Pokémon are immune to flinch, trap and confusion. Credit mult +0.15."
    when "Vigilance"
      desc = "Enemy Pokémon can't recieve critical hits for 999 turns. Credit mult +0.15."
    else
      desc = "Press Enter for more details."
    end
    @sprites["textbox"].text = _INTL(desc)
  end

  def pbEndScene
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) { pbUpdate }
    # Set the values of each option
    for i in 0...@BuffOptions.length
      @BuffOptions[i].set(@sprites["option"][i])
    end
    pbDisposeMessageWindow(@sprites["textbox"])
    pbDisposeSpriteHash(@sprites)
    pbRefreshSceneMap
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class EnemyBuffsScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(inloadscreen=false)
    @scene.pbStartScene(inloadscreen)
    @scene.pbOptions
    @scene.pbEndScene
  end
end


def loadEnemyBuffsScreen
  if $game_switches[694]
    if !(pbGet(50).is_a? EnemyBuffs)
      pbSet(50, EnemyBuffs.new)
    end
  elsif $game_switches[693]
    if !(pbGet(49).is_a? EnemyBuffs)
      pbSet(49, EnemyBuffs.new)
    end
  end
  pbPlayDecisionSE
  pbFadeOutIn {
    scene = EnemyBuffs_Scene.new
    screen = EnemyBuffsScreen.new(scene)
    screen.pbStartScreen
    pbUpdateSceneMap
  }
end
