#==============================================================================#
#                                   Quicksave                                  #
#                                    by Marin                                  #
#                  Edited for use in Pokémon Fire Ash by Luc-ker               #
#==============================================================================#
class Scene_Map
	alias quicksave_update update
  def update
    quicksave_update
    if Input.trigger?(Input::AUX1) && !$game_system.save_disabled #AUX1 refers to Q but can be changed by pressing F1
      pbSaveScreen
    elsif Input.trigger?(Input::AUX1) && $game_system.save_disabled
      pbMessage(_INTL("Can't save the game here!"))
    end
  end
end