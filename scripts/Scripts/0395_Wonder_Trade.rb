=begin
*** Wonder Trade Script by Black Eternity ***
*** Edited for use in Pokémon Fire Ash by Luc-ker***

This script is to mimic Wonder Trade from an offline perspective.
THERE IS NO ONLINE CAPABILITIES OF THIS SCRIPT,
ALL CALCULATIONS ARE DONE INTERNALLY.

To call the script like normal and have ALL Pokemon trade-able, use the following.
    pbWondertrade(1,[],[])

Black listed Pokemon are to be added to the Exceptions arrays.
  Except is the list of pokemon the player is forbidden to trade.
    Here the player cannot trade any of the following.
      pbWonderTrade(1,[:PIKACHU,:SQUIRTLE,:CHARMANDER,;BULBASAUR],[])

  Except2 is the list of pokemon the player is forbidden to receive.
    Here the player cannot receive any of the following.
      pbWonderTrade(1,[],[:MEWTWO,;MEW,;DEOXYS])

The first parameter is the minimum allowed Level of the Pokemon to be traded.
For example, you can not trade a Pokemon through Wonder Trade unless its level
is greater than or equal to specified level.

    pbWonderTrade(40,[:SQUIRTLE,:CHARMANDER,:BULBASAUR],[:MEWTWO,:MEW,:DEOXYS])
    *** Only pokemon over level 40 can be traded, you cannot trade starters.
    *** You cannot receive these legendaries.

The fourth parameter, which has recently replaced mej71's "hardobtain"
is called "rare", this parameter developed also by mej71, will use
the Pokemon's rareness and filter the results depending on its values.

** Rareness is turned on by default, if you wish to disable it, call the
    function accordingly.

    pbWonderTrade(10,[:SQUIRTLE],[:CHARMANDER,:BULBASAUR],false)
    ** Only Pokemon over level 10, cannot trade Squirtle, cannot
    ** recieve Charmander or Bulbasaur, Rareness disabled.

It is up to you to use it how you wish, credits will be appreciated.
=end

# List of Randomly selected Trainer Names
# These are just names taken from a generator, add custom or change to
# whatever you desire.
RandTrainerNames=[
["Luke",0],
["James",0],
["Keith",0],
["Matthew",0],
["Jeremy",0],
["Louis",0],
["Albert",0],
["Emily",1],
["Aaron",0],
["Frances",1],
["Steve",0],
["Joan",1],
["Dorothy",1],
["Jeffrey",0],
["Alice",1],
["Sara",1],
["David",0],
["Anne",1],
["Shirley",1],
["Henry",0],
["Carolyn",1],
["Christopher",0],
["Christina",1],
["Ronald",0],
["Randy",0],
["Nancy",1],
["Virginia",1],
["Donna",1],
["William",0],
["Jacqueline",1],
["Catherine",1],
["Jesse",0],
["Roger",0],
["Denise",1],
["Ashley",1],
["Maria",1],
["Todd",0],
["Helen",1],
["Teresa",1],
["Fred",0],
["Annie",1],
["Rachel",1],
["Kathleen",1],
["Marie",1],
["Scott",0],
["Phillip",0],
["Craig",0],
["Diane",1],
["Beverly",1],
["Lisa",1],
["Mildred",1],
["Lois",1],
["Douglas",0],
["Deborah",1],
["Phyllis",1],
["Melissa",1],
["Laura",1],
["Stephanie",1],
["Ernest",0],
["Evelyn",1],
["Irene",1],
["Brandon",0],
["Jean",0],
["Sandra",1],
["Linda",1],
["Raymond",0],
["Kathryn",1],
["Harry",0],
["Gary",0],
["Katherine",1],
["Theresa",1],
["Howard",0],
["Stephen",0],
["Russell",0],
["Bobby",0],
["Susan",1],
["Martin",0],
["Harold",0],
["Andrea",1],
["Sharon",1],
["Juan",0],
["Rose",0],
["Lori",1],
["Doris",1],
["Joseph",0],
["Charles",0],
["Donald",0],
["Arthur",0],
["Janice",1],
["Jack",0],
["Wanda",1],
["Ralph",0],
["Christine",1],
["Betty",1],
["Julia",1],
["Michelle",1],
["Kevin",0],
["James",0],
["Michael",0],
["Kathy",1],
["Norfolk",0],
["Jordan",0],
["Jessica",1]
]

# List of randomly selected Pokemon Nicknames
# These are just names taken from a generator, add custom or change to
# whatever you desire.
RandPokeNick=[
"Pyro",
"Nitro",
"Stormbringer",
"Monarch",
"Hotshot",
"Candy",
"Rey",
"Quaser",
"Woodle",
"Arc",
"Knuckles",
"Love",
"Shinobi",
"Cross",
"Gundam",
"Chappy",
"Yoko",
"Avian",
"Shadow Mist",
"Galatica",
"Colossus",
"Barry",
"Flash",
"Custom",
"Power",
"Bullet",
"Bujin",
"GG EZ",
"Juggernaut",
"Enigma",
"Marvelous",
"Beserk",
"Cyber",
"Bingo",
"Judgement",
"Stardust",
"Fluff",
"Sweet",
"Spark",
"Lucky",
"Liberty",
"Star",
"Cuddles",
"Ojama",
"Stratos",
"Liquid",
"Blaze",
"Utopia",
"Dystopia",
"Vulcan",
"Knight",
"Union",
"Double",
"Plasma",
"Voltic",
"Magma",
"Chaos",
"Hanzo",
"Kage",
"Baku",
"Rex",
"Dream",
"Miracle",
"Horus",
"Baron",
"Yuki",
"Ruby",
"Sapphire",
"Gold",
"Crystal",
"Shine",
"Chocolate",
"Apple",
"Orange",
"Strawberry",
"Marshmallow",
"Code",
"Red",
"Blue",
"Green",
"Pearl",
"Emerald",
"Diamond",
"Platinum",
"Sword",
"Shield",
"Scarlet",
"Violet",
"Burger",
"Carnival",
"Burrito",
"Terry",
"Shu",
"Akira",
"Aoi",
"Haruka",
"Yuki",
"Jun",
"Yuu",
"Kaoru"
]

def pbWonderTrade(lvl=1, except=[], except2=[], noLegend=true, free=false)
  if !free && $Trainer.money < 5000
    pbMessage(_INTL("\\rI'm sorry, but you need at least 5000 Poké Dollars to initiate a wonder trade."))
    return
  end
  $Trainer.money -= 5000 if !free
  pbMessage(_INTL("\\rGreat, let's begin!"))
  chosen = pbChoosePokemon(1,2, # Choose eligable pokemon
    proc {
    |poke| !poke.egg? && !(poke.isShadow?) && # No Eggs, No Shadow Pokemon
    (poke.level >= lvl) && !(except.include?(poke.species))
    })
  return if pbGet(1) < 0
  if noLegend
    except2.concat([
      :ARTICUNO,:ZAPDOS,:MOLTRES,:MEW,:MEWTWO,:RAIKOU,:ENTEI,:SUICUNE,:CELEBI,
      :LUGIA,:HOOH,:REGIROCK,:REGICE,:REGISTEEL,:LATIAS,:LATIOS,:TYPENULL,:SILVALLY,
      :KYOGRE,:GROUDON,:RAYQUAZA,:JIRACHI,:DEOXYS,:UXIE,:MESPRIT,:AZELF,
      :DIALGA,:PALKIA,:HEATRAN,:REGIGIGAS,:GIRATINA,:CRESSELIA,:PHIONE,:MANAPHY,
      :DARKRAI,:SHAYMIN,:ARCEUS,:VICTINI,:COBALION,:TERRAKION,:VIRIZION,
      :TORNADUS,:THUNDURUS,:RESHIRAM,:ZEKROM,:LANDORUS,:KYUREM,:KELDEO,
      :MELOETTA,:GENESECT,:XERNEAS,:YVELTAL,:ZYGARDE,:DIANCIE,:HOOPA,:VOLCANION,
      :TAPUKOKO,:TAPULELE,:TAPUBULU,:TAPUFINI,:COSMOG,:COSMOEM,:SOLGALEO,:LUNALA,
      :NIHILEGO,:BUZZWOLE,:PHEROMOSA,:XURKITREE,:CELESTEELA,:KARTANA,:GUZZLORD,
      :NECROZMA,:MAGEARNA,:MARSHADOW,:POIPOLE,:NAGANADEL,:STAKATAKA,:BLACEPHALON,
      :ZERAORA,:MELTAN,:MELMETAL,:ZACIAN,:ZAMAZENTA,:ETERNATUS,:KUBFU,:URSHIFU,
      :ZARUDE,:REGIELEKI,:REGIDRAGO,:GLASTRIER,:SPECTRIER,:CALYREX,:ENAMORUS
    ])
  end
  # The following excecption fields are for hardcoding the blacklisted pokemon
  # without adding them in the events.
  except += []
  except2 += []
  species_keys = []
  GameData::Species.each { |s| species_keys.push(s.species) if (s.form == 0 && 
                                                                !except2.include?(s.species)
                                                                )}
  new_species = species_keys.sample
  trainer = RandTrainerNames.sample # Randomizes Trainer Names
  tname = trainer[0]
  tgender = trainer[1]
  pname = RandPokeNick.sample # Randomizes Pokemon Nicknames
  pbStartTrade(pbGet(1),new_species,pname,tname,tgender,true) # Starts the trade
  pbSet(1, new_species)
end
