#==============================================================================#
#                         Better Fast-forward Mode                             #
#                                   v1.0                                       #
#                                                                              #
#                                 by Marin                                     #
#==============================================================================#
#                                   Usage                                      #
#                                                                              #
# SPEEDUP_STAGES are the speed stages the game will pick from. If you click F7 #
# it'll choose the next number in that array. It goes back to the first number #
#                                 afterward.                                   #
#                                                                              #
#             $GameSpeed is the current index in the speed up array.           #
#   Should you want to change that manually, you can do, say, $GameSpeed = 0   #
#                                                                              #
# If you don't want the user to be able to speed up at certain points, you can #
#                use "pbDisallowSpeedup" and "pbAllowSpeedup".                 #
#==============================================================================#
#                    Please give credit when using this.                       #
#==============================================================================#
#                 Edited for Essentials v19.1 by danzeedan.                    #
#                  Edited for Fire Ash by Maq47 & kraegon.                     #
#==============================================================================#

SPEED_SETTING_FILE = "Save Files/GameSpeedSetting.dat"
#SPEED_SETTING_FILE = RTP.getSaveFileName("GameSpeedSetting.dat") if (Object.const_defined?(:RTP) rescue false)

#==============================================================================
#          Methods for reading and saving game playback speed
#==============================================================================
def read_speed_setting
    if pbRgssExists?(SPEED_SETTING_FILE)
        return load_data(SPEED_SETTING_FILE)
    end
    return 1  # Set to default value if no file exists
end

def save_speed_setting(speed)
    save_data(speed, SPEED_SETTING_FILE)
end

#==============================================================================
#          Methods for setting the ability to change game speed
#==============================================================================
def pbAllowSpeedup
    $CanToggle = true
end

def pbDisallowSpeedup
    $CanToggle = false
end

#==============================================================================
#                           Initialize values
#==============================================================================
$GameSpeed = read_speed_setting
$SpeedTemp = 0
$frame = 0
$CanToggle = true

#==============================================================================
#                              Update values
#==============================================================================
module Graphics
    class << Graphics
        alias fast_forward_update update
    end

    def self.update
        if (Input.trigger?(Input::F7) || Input.trigger?(Input::AUX2)) && $CanToggle
            $GameSpeed += 1
            $GameSpeed = 1 if $GameSpeed >= 4
            save_speed_setting($GameSpeed)    # Stores the current playback speed after a change
        end
        $frame += 1
        return unless $frame % $GameSpeed == 0
        fast_forward_update
        $frame = 0
    end
end