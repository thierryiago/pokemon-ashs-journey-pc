#===============================================================================
# ZUD Settings.
#===============================================================================
module Settings

################################################################################  
# GENERAL  
################################################################################
# Visual Settings
#-------------------------------------------------------------------------------
  SHORTEN_MOVES  = true  # If true, shortens long names of Z-Moves/Max Moves in the fight menu. 
  DYNAMAX_SIZE   = true  # If true, Pokemon's sprites will become enlarged while Dynamaxed. (EBDX ignores this setting)
  DYNAMAX_COLOR  = true  # If true, applies a red overlay on the sprites of Dynamaxed Pokemon. (EBDX ignores this setting)
  GMAX_XL_ICONS  = false  # Set to "false" if using Pokemon icons provided by the Gen 8 Project.
#-------------------------------------------------------------------------------
# Dynamax Settings
#-------------------------------------------------------------------------------
  DMAX_ANYMAP    = false # If true, allows Dynamax on any map location.
  CAN_DMAX_WILD  = false # If true, allows Dynamax during normal wild encounters.
  DYNAMAX_TURNS  = 3     # The number of turns Dynamax lasts before expiring.
#-------------------------------------------------------------------------------
# Max Raid Settings
#-------------------------------------------------------------------------------
  MAXRAID_SIZE   = 3     # The base number of Pokemon you may have out in a Max Raid.
  MAXRAID_KOS    = 4     # The base number of KO's a Max Raid Pokemon needs beat you.
  MAXRAID_TIMER  = 10    # The base number of turns you have in a Max Raid battle.
  MAXRAID_SHIELD = 2     # The base number of hit points Max Raid shields have.
  
  
################################################################################  
# SWITCHES & VARIABLES  
################################################################################
# Switch Numbers
#-------------------------------------------------------------------------------
  NO_Z_MOVE      = 500    # The switch number for disabling Z-Moves.
  NO_ULTRA_BURST = 497    # The switch number for disabling Ultra Burst.
  NO_DYNAMAX     = 498    # The switch number for disabling Dynamax.
  NO_PLAYER_DYNAMAX = 571 # The switch number for only disabling Dynamax for the player.
  MAXRAID_SWITCH = 494    # The switch number used to toggle Max Raid battles.
  HARDMODE_RAID  = 495    # The switch number used to toggle Hard Mode raids.
  INFINITE_DMAX  = 575    # The switch number for making Dynamax last infinitely.
  
#-------------------------------------------------------------------------------
# Variable Numbers
#-------------------------------------------------------------------------------
  REWARD_BONUSES = 15    # The variable number used to store Raid Reward Bonuses.
  MAXRAID_PKMN   = 500   # The base variable number used to store a Raid Pokemon. There must not be any variables that use a number above this.
  
  
################################################################################  
# MECHANIC REQUIREMENTS
################################################################################
# Item Settings
#-------------------------------------------------------------------------------
# List of items that allow the use of Z-Moves/Ultra Burst or Dynamax.
#-------------------------------------------------------------------------------
  Z_RINGS        = [:ZRING,:ZPOWERRING]
  DMAX_BANDS     = [:DYNAMAXBAND]
#-------------------------------------------------------------------------------
# Map Settings
#-------------------------------------------------------------------------------
# Map ID's where Dynamax (POWERSPOTS) and Eternamax (ETERNASPOT) are allowed.
#-------------------------------------------------------------------------------
  POWERSPOTS     = [10,37,042,56,59,61,64,171,183,187,214,222,232,259,274,397,422,508,636,881,972,973,974,980,996]  # Pokemon Gyms, Pokemon League, Battle Facilities
  ETERNASPOT     = [508]                   # None by default
  
  
################################################################################  
# MAX RAID EXCEPTIONS 
################################################################################
# Legendary Exceptions
#-------------------------------------------------------------------------------
# The species added to this array are considered Legendary for the purposes of 
# Raids/Adventures, even if they don't meet the stat/egg group criteria of legendaries.
#-------------------------------------------------------------------------------
  LEGENDARY_EXCEPTIONS = []
  
#-------------------------------------------------------------------------------
# Regional Exceptions
#-------------------------------------------------------------------------------
# Determines regional forms eligible to appear in Raids/Adventures.
#-------------------------------------------------------------------------------
  ALOLA_REGION   = 6     # The region number designated as the Alola Region.
  GALAR_REGION   = 7     # The region number designated as the Galar Region.
  #-----------------------------------------------------------------------------
  # Array of all regional forms. 
  #-----------------------------------------------------------------------------
  # Each entry is its own array starting with the name of the regional form,
  # followed by the region number for that region, set above.
  #-----------------------------------------------------------------------------
  REGIONAL_FORMS = [
    ["Alolan",   ALOLA_REGION], # Forms with "Alolan" in their name.
    ["Galarian", GALAR_REGION], # Forms with "Galarian" in their name.
  ]
  #-----------------------------------------------------------------------------
end