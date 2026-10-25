### Misc. Methods for the game, idk where to put them lol ###
def gameCornerItemExchange
  item = pbGet(1)
  itemprice = pbGet(2)
  maxitems = $Trainer.coins/itemprice
  params = ChooseNumberParams.new
  params.setRange(1, maxitems)
  params.setInitialValue(1)
  params.setCancelValue(0)
  items = pbMessageChooseNumber(_INTL("\\CN\\bHow many {1} would you like? (max. {2})",
            GameData::Item.get(item).name_plural, maxitems), params)
  if items > 0
    if $PokemonBag.pbCanStore?(item, items)
      $Trainer.coins -= itemprice*items
      pbReceiveItem(item,items)
    else
      pbMessage(_INTL("\\CN\\bYou have no room in your Bag."))
    end
  end
end

def galarFossilCheck(var1=9,var2=10)
  head = [:FOSSILIZEDBIRD,:FOSSILIZEDFISH]
  body = [:FOSSILIZEDDRAKE,:FOSSILIZEDDINO]
  valid = [:FOSSILIZEDBIRD,:FOSSILIZEDFISH,:FOSSILIZEDDRAKE,:FOSSILIZEDDINO]
  if !valid.include?(pbGet(var1)) || !valid.include?(pbGet(var2))
    pbMessage(_INTL("\\rSorry, those fossils are outside of my expertise."))
  elsif pbGet(var1) == pbGet(var2)
    pbMessage(_INTL("\\rI can't revive a Pokémon using duplicate fossils."))
  elsif head.include?(pbGet(var1)) && head.include?(pbGet(var2))
    pbMessage(_INTL("\\rI can't revive a Pokémon using two head fossils."))
  elsif body.include?(pbGet(var1)) && body.include?(pbGet(var2))
    pbMessage(_INTL("\\rI can't revive a Pokémon using two body fossils."))
  else
    return true
  end
  return false
end

def getGalarMonFromFossils(var1=9,var2=10)
  heads = [:FOSSILIZEDBIRD,:FOSSILIZEDFISH]
  bodies = [:FOSSILIZEDDRAKE,:FOSSILIZEDDINO]
  if heads.include? pbGet(var1)
    head = pbGet(var1)
    body = pbGet(var2)
  else
    head = pbGet(var2)
    body = pbGet(var1)
  end
  if head == :FOSSILIZEDBIRD && body == :FOSSILIZEDDRAKE
    mon = :DRACOZOLT
  elsif head == :FOSSILIZEDBIRD && body == :FOSSILIZEDDINO
    mon = :ARCTOZOLT
  elsif head == :FOSSILIZEDFISH && body == :FOSSILIZEDDRAKE
    mon = :DRACOVISH
  elsif head == :FOSSILIZEDFISH && body == :FOSSILIZEDDINO
    mon = :ARCTOVISH
  end
  pbSet(3,mon)
end

def changeMapBg(bgName)
  $PokemonGlobal.tempBattleBack = bgName
end

def resetMapBg
  $PokemonGlobal.tempBattleBack = ""
end

def visitedCianwood?
  return $PokemonGlobal.visitedMaps[317]
end


