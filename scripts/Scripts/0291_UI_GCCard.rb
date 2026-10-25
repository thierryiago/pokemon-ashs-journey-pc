#===============================================================================
#
#===============================================================================
class GCCard_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    background = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/bg_f"))
    if $Trainer.female? && background
      addBackgroundPlane(@sprites,"bg","Trainer Card/bg_f",@viewport)
    else
      addBackgroundPlane(@sprites,"bg","Trainer Card/bg",@viewport)
    end
    return if $Trainer.outfit != 10
    @oldOutfit = $Trainer.outfit
    $Trainer.outfit = pbGet(GCVariables::TRAINER_OUTFIT)
  end
  
  def pbDrawGCCardOne
    pbStartScene
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/GCcardP1"))
    @sprites["card"] = IconSprite.new(0,0,@viewport)
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/GCcardP1")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,132,@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z = 2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour>0) ? _INTL("{1}h {2}m",hour,min) : _INTL("{1}m",min)
    credits = pbGet(80).to_s
    textPositions = [
       [_INTL("Practice"),52,76,0,baseColor,shadowColor],
       [_INTL("Club"),201,176,0,baseColor,shadowColor],
       [_INTL("ID No."),332,58,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
       [_INTL("Credits"),323,322,0,baseColor,shadowColor],
       [_INTL(credits),468-(credits.length-1)*12,321,0,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    imagePositions = []
    # Practice
    nd = (pbGet(91)>3) ? 3 : pbGet(91)
    imagePositions.push(["Graphics/Pictures/Trainer Card/Practice_medals",53,122,(nd-1)*84,0,84,84]) if nd > 0
    # Club
    nd = (pbGet(92)>4) ? 4 : pbGet(92)
    imagePositions.push(["Graphics/Pictures/Trainer Card/Club_ribbons",226,222,(nd-1)*36,0,36,84]) if nd > 0
    pbDrawImagePositions(overlay,imagePositions)
  end
  
  def pbDrawGCCardTwo
    pbStartScene
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/GCcardP2"))
    @sprites["card"] = IconSprite.new(0,0,@viewport)
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/GCcardP2")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,132,@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z = 2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    credits = pbGet(80).to_s
    textPositions = [
       [_INTL("Gauntlet"),31,63,0,baseColor,shadowColor],
       [_INTL("Duet"),133,63,0,baseColor,shadowColor],
       [_INTL("Mayhem"),234,63,0,baseColor,shadowColor],
       [_INTL("Sync"),82,202,0,baseColor,shadowColor],
       [_INTL("Titan"),184,202,0,baseColor,shadowColor],
       [_INTL("ID No."),332,58,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
       [_INTL("Credits"),323,322,0,baseColor,shadowColor],
       [_INTL(credits),468-(credits.length-1)*12,321,0,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    imagePositions = []
    # Gauntlet
    nd = -1
    tiers = [10,25,50]
    for i in 0...tiers.length
      nd = i if pbGet(93) >= tiers[i]
    end
    imagePositions.push(["Graphics/Pictures/Trainer Card/Gauntlet_embelems",33,108,nd*84,0,84,84]) if nd >= 0
    # Duet
    nd = pbGet(97)-1
    imagePositions.push(["Graphics/Pictures/Trainer Card/Duet_rings",140,114,nd*72,0,72,84]) if pbGet(97) > 0
    # Mayhem
    nd = pbGet(94)-1
    imagePositions.push(["Graphics/Pictures/Trainer Card/Mayhem_plaques",235,108,nd*84,0,84,72]) if pbGet(94) > 0
    # Sygna
    nd = pbGet(95)-1
    imagePositions.push(["Graphics/Pictures/Trainer Card/Sygna_medallions",98,250,nd*53,0,53,84]) if pbGet(95) > 0
    # Titan
    nd = pbGet(96)-1
    imagePositions.push(["Graphics/Pictures/Trainer Card/Titan_crowns",185,247,nd*84,0,84,84]) if pbGet(96) > 0
    pbDrawImagePositions(overlay,imagePositions)
  end
  
  def pbDrawGCCardThree
    pbStartScene
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/GCcardP3"))
    @sprites["card"] = IconSprite.new(0,0,@viewport)
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/GCcardP3")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,132,@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z = 2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    credits = pbGet(80).to_s
    textPositions = [
       [_INTL("Kanto"),31,63,0,baseColor,shadowColor],
       [_INTL("Johto"),133,63,0,baseColor,shadowColor],
       [_INTL("Hoenn"),234,63,0,baseColor,shadowColor],
       [_INTL("Sinnoh"),82,208,0,baseColor,shadowColor],
       [_INTL("Unova"),184,208,0,baseColor,shadowColor],
       [_INTL("ID No."),332,58,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
       [_INTL("Credits"),323,322,0,baseColor,shadowColor],
       [_INTL(credits),468-(credits.length-1)*12,321,0,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    imagePositions = []
    # Kanto
    nd = (pbGet(90)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Kanto#{nd}",30,106,0,0,90,90]) if pbGet(90)>0
    # Johto
    nd = (pbGet(89)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Johto#{nd}",130,106,0,0,90,90]) if pbGet(89)>0
    # Hoenn
    nd = (pbGet(88)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Hoenn#{nd}",230,106,0,0,90,90]) if pbGet(88)>0
    # Sinnoh
    nd = (pbGet(87)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Sinnoh#{nd}",80,251,0,0,90,90]) if pbGet(87)>0
    # Unova
    nd = (pbGet(86)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Unova#{nd}",180,251,0,0,90,90]) if pbGet(86)>0
    pbDrawImagePositions(overlay,imagePositions)
  end
  
  def pbDrawGCCardFour
    pbStartScene
    cardexists = pbResolveBitmap(sprintf("Graphics/Pictures/Trainer Card/GCcardP3"))
    @sprites["card"] = IconSprite.new(0,0,@viewport)
    @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/GCcardP3")
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,132,@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-128)
    @sprites["trainer"].z = 2
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(72,72,72)
    shadowColor = Color.new(160,160,160)
    credits = pbGet(80).to_s
    textPositions = [
       [_INTL("Kalos"),31,63,0,baseColor,shadowColor],
       [_INTL("Alola"),133,63,0,baseColor,shadowColor],
       [_INTL("Galar"),234,63,0,baseColor,shadowColor],
       [_INTL("Frontier"),82,208,0,baseColor,shadowColor],
       [_INTL("Hisui"),184,208,0,baseColor,shadowColor],
       [_INTL("ID No."),332,58,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
       [_INTL("Credits"),323,322,0,baseColor,shadowColor],
       [_INTL(credits),468-(credits.length-1)*12,321,0,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    imagePositions = []
    # Kalos
    nd = (pbGet(85)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Kalos#{nd}",30,106,0,0,90,90]) if pbGet(85)>0
    # Alola
    nd = (pbGet(84)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Alola#{nd}",130,106,0,0,90,90]) if pbGet(84)>0
    # Galar
    nd = (pbGet(48)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Galar#{nd}",230,105,0,0,90,90]) if pbGet(48)>0
    # Frontier
    nd = (pbGet(83)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Frontier#{nd}",80,251,0,0,90,90]) if pbGet(83)>0
    # Hisui
    nd = (pbGet(47)>=2) ? "2" : ""
    imagePositions.push(["Graphics/Pictures/Trainer Card/Hisui#{nd}",180,251,0,0,90,90]) if pbGet(47)>0
    pbDrawImagePositions(overlay,imagePositions)
  end

  def pbGCCardOne
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenTwo
        break
      elsif Input.trigger?(Input::LEFT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenFour
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        pbEndScene
        break
      end
    end
  end
  
  def pbGCCardTwo
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenThree
        break
      elsif Input.trigger?(Input::LEFT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenOne
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        pbEndScene
        break
      end
    end
  end
  
  def pbGCCardThree
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenFour
        break
      elsif Input.trigger?(Input::LEFT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenTwo
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        pbEndScene
        break
      end
    end
  end
  
  def pbGCCardFour
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::RIGHT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenOne
        break
      elsif Input.trigger?(Input::LEFT)
        pbEndScene
        scene = GCCard_Scene.new
        screen = GCCardScreen.new(scene)
        screen.pbScreenThree
        break
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        pbEndScene
        break
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    $Trainer.outfit = @oldOutfit if @oldOutfit
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class GCCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbScreenOne
    @scene.pbDrawGCCardOne
    @scene.pbFadeInAndShow(@sprites) { pbUpdate }
    @scene.pbGCCardOne
  end
  
  def pbScreenTwo
    @scene.pbDrawGCCardTwo
    @scene.pbFadeInAndShow(@sprites) { pbUpdate }
    @scene.pbGCCardTwo
  end
  
  def pbScreenThree
    @scene.pbDrawGCCardThree
    @scene.pbFadeInAndShow(@sprites) { pbUpdate }
    @scene.pbGCCardThree
  end
  
  def pbScreenFour
    @scene.pbDrawGCCardFour
    @scene.pbFadeInAndShow(@sprites) { pbUpdate }
    @scene.pbGCCardFour
  end
end
