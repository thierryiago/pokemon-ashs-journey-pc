#===============================================================================
# * Hall of Fame - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It makes a recordable Hall of Fame
# like the Gen 3 games.
#
#===============================================================================
#
# To this scripts works, put it above main, put a 512x384 picture in
# hallfamebars and a 8x24 background picture in hallfamebg. To call this script,
# use 'pbHallOfFameEntry'. After you recorder the first entry, you can access
# the hall teams using a PC. You can also check the player Hall of Fame last
# number using '$PokemonGlobal.hallOfFameLastNumber'.
#
#===============================================================================
class Challenge_Scene
  # When true, all pokémon will be in one line
  # When false, all pokémon will be in two lines
  SINGLEROW = false
  # Make the pokémon movement ON in hall entry
  ANIMATION = false
  # Speed in pokémon movement in hall entry. Don't use less than 2!
  ANIMATIONSPEED = 32
  # Entry wait time (in 1/20 seconds) between showing each Pokémon (and trainer)
  ENTRYWAITTIME = 64
  # Maximum number limit of simultaneous hall entries saved.
  # 0 = Doesn't save any hall. -1 = no limit
  # Prefer to use larger numbers (like 500 and 1000) than don't put a limit
  # If a player exceed this limit, the first one will be removed
  HALLLIMIT = -1
  # The entry music name. Put "" to doesn't play anything
  ENTRYMUSIC = "Hall of Fame"
  # Allow eggs to be show and saved in hall
  ALLOWEGGS = true
  # Remove the hallbars when the trainer sprite appears
  REMOVEBARS = true
  # The final fade speed on entry
  FINALFADESPEED = 16
  # Sprites opacity value when them aren't selected
  OPACITY = 64
  BASECOLOR   = Color.new(248,248,248)
  SHADOWCOLOR = Color.new(0,0,0)

  # Placement for pokemon icons
  def pbStartScene
    @sprites={}
    @viewport=Viewport.new(0,0,Graphics.width, Graphics.height)
    @viewport.z=99999
    # Comment the below line to doesn't use a background
    addBackgroundPlane(@sprites,"bg","hallfamebg",@viewport)
    @sprites["hallbars"]=IconSprite.new(@viewport)
    @sprites["hallbars"].setBitmap("Graphics/Pictures/hallfamebars")
    @sprites["overlay"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["overlay"].z=10
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @alreadyFadedInEnd=false
    @useMusic=false
    @battlerIndex=0
    @size = $Trainer.party.length
  end

  def pbStartScenePC
    pbStartScene
    createBattlers
    pbFadeInAndShow(@sprites) { pbUpdate }
    pbUpdatePC
  end

  def pbEndScene
    $game_map.autoplay if @useMusic
    pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites.include?("msgwindow")
    pbFadeOutAndHide(@sprites) { pbUpdate } if !@alreadyFadedInEnd
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

  def slowFadeOut(sprites,exponent)   # 2 exponent
    # To handle values above 8
    extraWaitExponent=exponent-9
    exponent=8 if 8<exponent
    max=2**exponent
    speed=(2**8)/max
    for j in 0..max
      if extraWaitExponent>-1
        (2**extraWaitExponent).times do
          Graphics.update
          Input.update
          pbUpdate
        end
      end
      pbSetSpritesToColor(sprites,Color.new(0,0,0,j*speed))
      block_given? ? yield : pbUpdateSpriteHash(sprites)
    end
  end

  # Change the pokémon sprites opacity except the index one
  def setPokemonSpritesOpacity(index,opacity=255)
    for n in 0...@size
      @sprites["pokemon#{n}"].opacity=(n==index) ? 255 : opacity if @sprites["pokemon#{n}"]
    end
  end

  # Return the x/y point position in screen for battler index number
  # Don't use odd numbers!
  def xpointformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=32+160*xpositionformula(battlernumber)
    else
      ret=(60*(battlernumber/2)+48)*(xpositionformula(battlernumber)-1)
      ret+=Graphics.width/2-56
    end
    return ret
  end

  def ypointformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=32+128*ypositionformula(battlernumber)/2
    else
      ret=96-8*(battlernumber/2)
    end
    return ret
  end

  # Returns 0, 1 or 2 as the x/y column value
  def xpositionformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=(battlernumber/3%2==0) ? (19-battlernumber)%3 : (19+battlernumber)%3
    else
      ret=battlernumber%2*2
    end
    return ret
  end

  def ypositionformula(battlernumber)
    ret=0
    if !SINGLEROW
      ret=(battlernumber/3)%2*2
    else
      ret=1
    end
    return ret
  end

  def createBattlers
    # Movement in animation
    for i in 0...6
      next if i>=@size
      xpoint=xpointformula(i)
      ypoint=ypointformula(i)
      pok=$Trainer.party[i]
      @sprites["pokemon#{i}"]=PokemonSprite.new(@viewport)
      @sprites["pokemon#{i}"].setOffset(PictureOrigin::TopLeft)
      @sprites["pokemon#{i}"].setPokemonBitmap(pok)
      # This method doesn't put the exact coordinates
      @sprites["pokemon#{i}"].x = xpoint
      @sprites["pokemon#{i}"].y = ypoint
      if @sprites["pokemon#{i}"].bitmap && !@sprites["pokemon#{i}"].disposed?
        @sprites["pokemon#{i}"].x += (128-@sprites["pokemon#{i}"].bitmap.width)/2
        @sprites["pokemon#{i}"].y += (128-@sprites["pokemon#{i}"].bitmap.height)/2
      end
      @sprites["pokemon#{i}"].z=7-i if SINGLEROW
    end
  end

  def writePokemonData(pokemon)
    overlay=@sprites["overlay"].bitmap
    overlay.clear
    pokename=pokemon.name
    speciesname=pokemon.speciesName
    if pokemon.male?
      speciesname+="♂"
    elsif pokemon.female?
      speciesname+="♀"
    end
    pokename+="/"+speciesname
    pokename=_INTL("Egg")+"/"+_INTL("Egg") if pokemon.egg?
    idno=(pokemon.owner.name.empty? || pokemon.egg?) ? "?????" : sprintf("%05d",pokemon.owner.public_id)
    dexnumber = _INTL("No. ???")
    if !pokemon.egg?
      species_data = GameData::Species.get(pokemon.species)
      dexnumber = _ISPRINTF("No. {1:03d}",species_data.id_number)
    end
    textPositions=[
       [dexnumber,32,Graphics.height-86,0,BASECOLOR,SHADOWCOLOR],
       [pokename,Graphics.width-192,Graphics.height-86,2,BASECOLOR,SHADOWCOLOR],
       [_INTL("Lv. {1}",pokemon.egg? ? "?" : pokemon.level),
           64,Graphics.height-54,0,BASECOLOR,SHADOWCOLOR],
       [_INTL("IDNo.{1}",pokemon.egg? ? "?????" : idno),
           Graphics.width-192,Graphics.height-54,2,BASECOLOR,SHADOWCOLOR]
    ]
    diff = ""
    if $game_switches[676]
      diff = " - Practice"
    elsif $game_switches[677]
      diff = " - Veteran"
    elsif $game_switches[678]
      diff = " - Ace"
    elsif $game_switches[689]
      diff = " - Master"
    end
    cName = ""
    if $game_switches[699]
      cName = "Practice"
    elsif $game_switches[698]
      cName = "Club"
    elsif $game_switches[697]
      cName = "Gauntlet"
    elsif $game_switches[696]
      cName = "Mayhem"
    elsif $game_switches[694]
      cName = "Sync"
    elsif $game_switches[693]
      cName = "Titan"
    elsif $game_switches[692]
      cName = "Duet"
    elsif $game_switches[690] || $game_switches[700]
      cName = "DESPAIR"
    end
    header = "#{cName} Challenge Team#{diff}"
    textPositions.push([_INTL(header),Graphics.width/2-5*header.length,-6,0,BASECOLOR,SHADOWCOLOR])
    pbDrawTextPositions(overlay,textPositions)
  end

  def pbAnimationLoop
    loop do
      Graphics.update
      Input.update
      pbUpdate
    end
  end

  def pbPCSelection
    loop do
      Graphics.update
      Input.update
      pbUpdate
      continueScene=true
      break if Input.trigger?(Input::BACK)   # Exits
      if Input.trigger?(Input::LEFT)   # Moves the selection one pokémon forward
        @battlerIndex-=1
        continueScene=pbUpdatePC
      end
      if Input.trigger?(Input::RIGHT)   # Moves the selection one pokémon backward
        @battlerIndex+=1
        continueScene=pbUpdatePC
      end
      if Input.trigger?(Input::UP)   # Generate IDs
        ids = []
        for pokemon in $Trainer.party
          idno=(pokemon.owner.name.empty? || pokemon.egg?) ? "?????" : sprintf("%05d",pokemon.owner.public_id)
          ids.push(idno)
        end
        ids = ids*", "
        pbMessage(_INTL("{1}",ids))
      end
      break if !continueScene
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdatePC
    # Bound checking
    if @battlerIndex>=@size
      @battlerIndex = 0
    elsif @battlerIndex<0
      @battlerIndex = @size - 1
    end
    # Change the pokemon
    $Trainer.party[@battlerIndex].play_cry
    setPokemonSpritesOpacity(@battlerIndex,OPACITY)
    writePokemonData($Trainer.party[@battlerIndex])
    return true
  end
end

#===============================================================================
#
#===============================================================================
class ChallengeScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreenPC
    @scene.pbStartScenePC
    @scene.pbPCSelection
    @scene.pbEndScene
  end
end


#===============================================================================
#
#===============================================================================
def pbChallengePC
  scene=Challenge_Scene.new
  screen=ChallengeScreen.new(scene)
  screen.pbStartScreenPC
end
