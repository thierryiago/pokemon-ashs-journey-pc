# Functions in order to vary the music that gets played in game (by Luc-ker)
def playHealingME
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  coords = (map_metadata) ? map_metadata.town_map_position : nil
  if coords && coords[0] >= 0 && coords[0] <= 7
    regions = {
      0 => "Kanto",
      1 => "Johto",
      2 => "Hoenn",
      3 => "Sinnoh",
      4 => "Unova",
      5 => "Kalos",
      6 => "Alola",
      7 => "Galar",
    }
    region = regions[coords[0]]
    me_name = "Deluxe/#{region}/Pokemon Healing"
    if FileTest.audio_exist?("Audio/ME/" + me_name)
      pbMEPlay(me_name)
      return
    end
  end
  pbMEPlay("Pokemon Healing")
end

def playOakLabBGM
  bgm_name = "Deluxe/Kanto/Oak's Lab"
  playingBGM = $game_system.playing_bgm
  pbBGMPlay(bgm_name) if (FileTest.audio_exist?("Audio/BGM/" + bgm_name) &&
                          (!playingBGM || playingBGM.name != bgm_name))
end
