module Input
  USE      = C
  BACK     = B # may be reinterpreted as A if user enables swap_back_action opt
  ACTION   = A # may be reinterpreted as B if user enables swap_back_action opt
  JUMPUP   = X
  JUMPDOWN = Y
  SPECIAL  = Z
  AUX1     = L
  AUX2     = R

  unless defined?(update_KGC_ScreenCapture)
    class << Input
      alias update_KGC_ScreenCapture update
    end
  end
    
  unless defined?(def_press?)
    class << Input
      alias def_press? press?
    end
  end
    
  unless defined?(def_repeat?)
    class << Input
      alias def_repeat? repeat?
    end
  end
  
  unless defined?(def_trigger?)
    class << Input
      alias def_trigger? trigger?
    end
  end
  
  class << self
    def resolve(key) # respect swap_back_action
      if $PokemonSystem && $PokemonSystem.swap_back_action == 1
        if key == ACTION
          key = BACK
        elsif key == BACK
          key = ACTION
        end
      end
      
      return key
    end
    
    def update
      update_KGC_ScreenCapture
      pbScreenCapture if trigger?(Input::F8)
    end
    
    def press?(key)
      return def_press?(resolve(key))
    end
    
    def repeat?(key)
      return def_repeat?(resolve(key))
    end
    
    def trigger?(key)
      return def_trigger?(resolve(key))
    end
  end
end

module Mouse
  module_function

  # Returns the position of the mouse relative to the game window.
  def getMousePos(catch_anywhere = false)
    return nil unless System.mouse_in_window || catch_anywhere
    return Input.mouse_x, Input.mouse_y
  end
end
