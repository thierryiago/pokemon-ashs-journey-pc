#==============================================================================#
# Sync + Titan Challenge Buffs
#==============================================================================#
# Switches:
# 57 - Sygna Buff Energy (max 7)
# 58 - Owned Buffs
# 59 - Active Buffs
# 62 - Array storing yet-to-be-bought Sygna Buffs
#==============================================================================#
class SygnaBuff
  attr_accessor :name
  attr_accessor :level # also doubles as buff cost when making it an active buff
  attr_accessor :max_level
  attr_accessor :buff_type
  attr_accessor :cost
  attr_accessor :description
  attr_accessor :stat
  
  def initialize(name,description,cost,stat=nil)
    @name = name
    @buff_type = name.split[1]
    @buff_type = "Immunity" if !(["Blessing", "Recovery", "Booster", "Crusher"].include?(@buff_type))
    @max_level = (@buff_type == "Recovery") ? 3 : 2
    @max_level = 1 if ["Assassin's Blessing Lv. 1", "Full Healing"].include?(name)
    @level = name[-1].to_i
    @level = 1 if ["Booster", "Crusher"].include?(@buff_type)
    @level = 2 if @buff_type == "Immunity"
    @level = 3 if ["Highest Vigilance", "Status Recovery"].include?(name)
#    @level = 7 if name == "Full Healing"
    @cost = cost
    @cost = cost*5 if @level == 2 && @buff_type == "Blessing"
    @description = _INTL("All your Pokémon have +{1} {2} when entering a battle.",
                          @level,
                          GameData::Stat.get(stat).name
                          ) if @buff_type == "Blessing"
    @description = description
    @stat = stat
  end
  
  def showDetails
    pbMessage(_INTL("{1} - {2}", name, description))
  end
end

def setUpBuffShop
  pbSet(62,[
    SygnaBuff.new("Warrior's Blessing Lv. 1", nil, 7, :ATTACK),
    SygnaBuff.new("Knight's Blessing Lv. 1", nil, 7, :DEFENSE),
    SygnaBuff.new("Warlock's Blessing Lv. 1", nil, 7, :SPECIAL_ATTACK),
    SygnaBuff.new("Paladin's Blessing Lv. 1", nil, 7, :SPECIAL_DEFENSE),
    SygnaBuff.new("Assassin's Blessing Lv. 1", nil, 10, :SPEED),
    SygnaBuff.new("Archer's Blessing Lv. 1", nil, 9, :ACCURACY),
    SygnaBuff.new("Antitoxin", "Your Pokémon can't be poisoned.", 10),
    SygnaBuff.new("Flameproof", "Your Pokémon can't be burned.", 10),
    SygnaBuff.new("Lithe", "Your Pokémon can't be paralyzed.", 10),
    SygnaBuff.new("Antifreeze", "Your Pokémon can't be frozen.", 10),
    SygnaBuff.new("Wide Awake", "Your Pokémon can't be put to sleep.", 10),
    SygnaBuff.new("Clearheaded", "Your Pokémon can't become confused.", 10),
    SygnaBuff.new("Unflappable", "Your Pokémon can't flinch.", 10),
    SygnaBuff.new("Escape Artist", "Your Pokémon can't be trapped.", 10),
    SygnaBuff.new("Vigilance", "Your Pokémon won't recieve critical hits for 3 turns.", 12)
  ])
  pbSet(57,[7])
  pbSet(58,[])
  pbSet(59,[])
end

def showShopBuffs
  choices = ""
  pbGet(62).each do |b|
    choices = "#{choices},#{b.name} - #{b.cost} GC Credits"
  end
  pbMessage(_INTL("YOU HAVE \\v[80] CREDITS IN YOUR ACCOUNT. WHICH BUFF WOULD YOU LIKE TO BUY?\\ch[75,-1,#{choices[1...]}]"))
end

def buyBuff
  buff = pbGet(62)[pbGet(75)]
  if buff.cost > pbGet(80)
    pbMessage(_INTL("NOT ENOUGH CREDITS."))
    return
  end
  pbSet(80,pbGet(80) - buff.cost)
  pbMessage(_INTL("BOUGHT {1}.", buff.name))
  pbGet(58).push(SygnaBuff.new(buff.name,buff.description,buff.cost,buff.stat))
  if buff.buff_type == "Blessing" and buff.level < buff.max_level
    pbGet(62)[pbGet(75)] = SygnaBuff.new("#{buff.name.chop}#{buff.level+1}",buff.description,buff.cost,buff.stat)
  elsif buff.buff_type == "Recovery" and buff.level < buff.max_level
    type = buff.name.split[0]
    new_lv = buff.level + 1
    descriptions = {
      "HP2" => "Increase the amount of HP restored for each Pokémon from Nurse Joy to 50% of its max HP. Sync Challenge only.",
      "HP3" => "Nurse Joy fully restores the HP of the Pokémon on your team. Sync Challenge only.",
      "PP2" => "Increase the amount of PP restored for each Pokémon's moves from Nurse Joy to 1/2 of its max PP. Sync Challenge only.",
      "PP3" => "Nurse Joy fully restores the PP of your party Pokémon's moves. Sync Challenge only."
    }
    pbGet(62)[pbGet(75)] = SygnaBuff.new("#{buff.name.chop}#{new_lv}",descriptions["#{type}#{new_lv}"],buff.cost*2)
  else
    pbGet(62).delete_at(pbGet(75))
  end
  shopUpdate?
end

def viewOwnedBuffs(varNum)
  buffs = ""
  pbGet(varNum).each do |b|
    buffs = "#{buffs},#{b.name}"
  end
  pbMessage(_INTL("SELECT A BUFF.\\ch[75,-1,#{buffs[1...]}]"))
end
  
def equipBuff
  buff = pbGet(58)[pbGet(75)]
  diff = buff.level - pbGet(57)[0]
  if diff > 0
    pbMessage(_INTL("NEED #{diff} MORE ENERGY TO EQUIP THIS BUFF."))
    return
  end
  pbGet(59).push(buff)
  pbGet(57)[0] -= buff.level
  pbMessage(_INTL("EQUIPPED {1}.", buff.name))
  pbGet(58).delete_at(pbGet(75))
end

def unequipBuff
  buff = pbGet(59)[pbGet(75)]
  pbGet(58).push(buff)
  pbGet(57)[0] += buff.level
  pbMessage(_INTL("UNEQUIPPED {1}.", buff.name))
  pbGet(59).delete_at(pbGet(75))
end

def buffInArray(buff, varNum)
  arr = pbGet(varNum)
  return false if !(arr.is_a? Array) || arr.empty?
  arr.each do |b|
    return true if b.name == buff
  end
  return false
end

def ownedBuff(buff)
  return (buffInArray(buff, 58) || buffInArray(buff, 59))
end

def hasActiveBuff(buff)
  return buffInArray(buff, 59)
end

def buffInShop(buff)
  return buffInArray(buff, 62)
end

def shouldAddToBuffShop?(buffName)
  return !buffInShop(buffName) && !ownedBuff(buffName)
end

# To add new buffs to shop, use this method
def shopUpdate?
  # Add at any time (when shop is initially set up, or is empty)
  if shouldAddToBuffShop?("Brawn Booster")
    buff = SygnaBuff.new(
      "Brawn Booster",
      "Your Pokémon gain +1 Attack after using a move.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Guard Booster")
    buff = SygnaBuff.new(
      "Guard Booster",
      "Your Pokémon gain +1 Defense after using a move.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Brain Booster")
    buff = SygnaBuff.new(
      "Brain Booster",
      "Your Pokémon gain +1 Sp. Attack after using a move.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Mind Booster")
    buff = SygnaBuff.new(
      "Mind Booster",
      "Your Pokémon gain +1 Sp. Defense after using a move.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Speed Booster")
    buff = SygnaBuff.new(
      "Speed Booster",
      "Your Pokémon gain +1 Speed after using a move.",
      15)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Brawn Crusher")
    buff = SygnaBuff.new(
      "Brawn Crusher",
      "Opponents get -1 Attack after being attacked. Sync Challenge only.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Guard Crusher")
    buff = SygnaBuff.new(
      "Guard Crusher",
      "Opponents get -1 Defense after being attacked. Sync Challenge only.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Brain Crusher")
    buff = SygnaBuff.new(
      "Brain Crusher",
      "Opponents get -1 Sp. Attack after being attacked. Sync Challenge only.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Mind Crusher")
    buff = SygnaBuff.new(
      "Mind Crusher",
      "Opponents get -1 Sp. Defense after being attacked. Sync Challenge only.",
      10)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Speed Crusher")
    buff = SygnaBuff.new(
      "Speed Crusher",
      "Opponents get -1 Speed after being attacked. Sync Challenge only.",
      15)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("HP Recovery Lv. 1")
    buff = SygnaBuff.new(
      "HP Recovery Lv. 1",
      "Increase the amount of HP restored for each Pokémon from Nurse Joy to 25% of its max HP. Sync Challenge only.",
      25)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("PP Recovery Lv. 1")
    buff = SygnaBuff.new(
      "PP Recovery Lv. 1",
      "Increase the amount of PP restored for each Pokémon's moves from Nurse Joy to 1/4 of its max PP. Sync Challenge only.",
      25)
    pbGet(62).push(buff)
  end
  if shouldAddToBuffShop?("Status Recovery")
    buff = SygnaBuff.new(
      "Status Recovery",  # This buff costs 3 energy
      "Nurse Joy removes status conditions from your team. Costs 3 energy. Sync Challenge only.",
      25)
    pbGet(62).push(buff)
  end
  # Add when shop is empty
  if pbGet(62).length == 0
    if !ownedBuff("Status Immunity")
      buff = SygnaBuff.new(
        "Status Immunity",
        "Your Pokémon are immune to status conditions.", 50)
      buff.level = 4
      pbGet(62).push(buff)
    end
    if !ownedBuff("Interference Immunity")
      buff = SygnaBuff.new(
        "Interference Immunity",
        "Your Pokémon are immune to being flinched, trapped or confused.", 33)
      buff.level = 3
      pbGet(62).push(buff)
    end
    if !ownedBuff("Highest Vigilance")  # This buff costs 3 energy
      buff = SygnaBuff.new(
        "Highest Vigilance",
        "Your Pokémon won't recieve critical hits for 999 turns. Costs 3 energy.", 48)
      pbGet(62).push(buff)
    end
    # Full Healing was a nice idea but tbh I think it makes it too easy, esp
    # with Perish Song + Destiny Bond
#    if ownedBuff("HP Recovery Lv. 3") && ownedBuff("PP Recovery Lv. 3") &&
#        !ownedBuff("Full Healing")  # This buff costs 7 energy
#      buff = SygnaBuff.new(
#        "Full Healing","Nurse Joy heals your team properly. Unable to equip other buffs. Sync Challenge only.",250)
#      pbGet(62).push(buff)
#    end
  end
end

=begin
def setUpEnemyBuff
  pbSet(52,[
    # Lv 1 stat buffs
    SygnaBuff.new("Warrior's Blessing Lv. 1",
      "Enemy Pokémon have +1 Attack when entering battle.", 0.1, :ATTACK),
    SygnaBuff.new("Knight's Blessing Lv. 1",
      "Enemy Pokémon have +1 Defense when entering battle.", 0.1, :DEFENSE),
    SygnaBuff.new("Warlock's Blessing Lv. 1",
      "Enemy Pokémon have +1 Sp. Attack when entering battle.", 0.1, :SPECIAL_ATTACK),
    SygnaBuff.new("Paladin's Blessing Lv. 1",
      "Enemy Pokémon have +1 Sp. Defense when entering battle.", 0.1, :SPECIAL_DEFENSE),
    SygnaBuff.new("Assassin's Blessing Lv. 1",
      "Enemy Pokémon have +1 Speed when entering battle.", 0.25, :SPEED),
    SygnaBuff.new("Archer's Blessing Lv. 1",
      "Enemy Pokémon have +1 Accuracy when entering battle.", 0.1, :ACCURACY),
    SygnaBuff.new("Ninja's Blessing Lv. 1",
      "Enemy Pokémon have +1 Evasion when entering battle.", 0.25, :EVASION),
    # Lv 2 stat buffs
    SygnaBuff.new("Warrior's Blessing Lv. 1",
      "Enemy Pokémon have +2 Attack when entering battle.", 0.2, :ATTACK),
    SygnaBuff.new("Knight's Blessing Lv. 2",
      "Enemy Pokémon have +2 Defense when entering battle.", 0.2, :DEFENSE),
    SygnaBuff.new("Warlock's Blessing Lv. 2",
      "Enemy Pokémon have +2 Sp. Attack when entering battle.", 0.2, :SPECIAL_ATTACK),
    SygnaBuff.new("Paladin's Blessing Lv. 2",
      "Enemy Pokémon have +2 Sp. Defense when entering battle.", 0.2, :SPECIAL_DEFENSE),
    SygnaBuff.new("Assassin's Blessing Lv. 2",
      "Enemy Pokémon have +2 Speed when entering battle.", 0.5, :SPEED),
    SygnaBuff.new("Archer's Blessing Lv. 2",
      "Enemy Pokémon have +2 Accuracy when entering battle.", 0.2, :ACCURACY),
    SygnaBuff.new("Ninja's Blessing Lv. 2",
      "Enemy Pokémon have +2 Evasion when entering battle.", 0.5, :EVASION),
    # Lv 3 stat buffs
    SygnaBuff.new("Warrior's Blessing Lv. 3",
      "Enemy Pokémon have +3 Attack when entering battle.", 0.3, :ATTACK),
    SygnaBuff.new("Knight's Blessing Lv. 3",
      "Enemy Pokémon have +3 Defense when entering battle.", 0.3, :DEFENSE),
    SygnaBuff.new("Warlock's Blessing Lv. 3",
      "Enemy Pokémon have +3 Sp. Attack when entering battle.", 0.3, :SPECIAL_ATTACK),
    SygnaBuff.new("Paladin's Blessing Lv. 3",
      "Enemy Pokémon have +3 Sp. Defense when entering battle.", 0.3, :SPECIAL_DEFENSE),
    SygnaBuff.new("Assassin's Blessing Lv. 3",
      "Enemy Pokémon have +3 Speed when entering battle.", 0.75, :SPEED),
    SygnaBuff.new("Archer's Blessing Lv. 3",
      "Enemy Pokémon have +3 Accuracy when entering battle.", 0.3, :ACCURACY),
    SygnaBuff.new("Ninja's Blessing Lv. 3",
      "Enemy Pokémon have +3 Evasion when entering battle.", 0.75, :EVASION),
    # Other buffs
    SygnaBuff.new("Status Immunity",
      "Enemy Pokémon are immune to status conditions.", 0.25),
    SygnaBuff.new("Interference Immunity",
      "Your Pokémon are immune to being flinched, trapped or confused.", 0.2),
    SygnaBuff.new("Highest Vigilance",
      "Enemy Pokémon are immune to critical hits.", 0.15)
  ])
  pbSet(49,[]) # Active buffs
end
=end

def calcCreditsWithBuffs
  varNum = ($game_switches[693]) ? 49 : 50
  buffs = pbGet(varNum)
  creds = pbGet(GCVariables::SYGNA_CREDITS)
  return creds if !buffs.is_a?(EnemyBuffs)
  creds = (creds * buffs.getCreditMultiplier).floor
  pbGet(GCVariables::SYGNA_CREDITS, creds)
  return creds
end
