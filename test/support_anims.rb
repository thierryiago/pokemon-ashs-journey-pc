# Dublês para carregar as animações reais do Fire Ash (Data/PkmnAnimations.rxdata)
# fora do jogo. Usado por test/rt_anim_test.rb.
require 'yaml'
class PBAnimations < Array
  def [](i) = @array[i]
  def length = @array.length
end
class PBAnimation < Array
  attr_reader :graphic, :hue, :timing, :name
  def [](i) = @array[i]
  def length = @array.length
end
class PBAnimTiming
  attr_reader :frame, :name, :volume, :pitch
  def timingType = @timingType || 0
end
module RPG; class AudioFile; end; end unless defined?(RPG::AudioFile)
class Color; end unless defined?(Color)
class Color; def self._load(s) = new; end unless Color.respond_to?(:_load)
class AnimFrame
  X = 0; Y = 1; ZOOMX = 2; ANGLE = 3; MIRROR = 4; BLENDTYPE = 5; VISIBLE = 6; PATTERN = 7; OPACITY = 8
  ZOOMY = 11; COLORRED = 12; COLORGREEN = 13; COLORBLUE = 14; COLORALPHA = 15; TONERED = 16
  TONEGREEN = 17; TONEBLUE = 18; TONEGRAY = 19; FOCUS = 26
end
ROOT_DIR = File.expand_path('..', __dir__)
$test_anims = Marshal.load(File.binread("#{ROOT_DIR}/Data/PkmnAnimations.rxdata"))
$test_m2a = Marshal.load(File.binread("#{ROOT_DIR}/Data/move2anim.dat"))
$test_move_nums = YAML.load_file("#{ROOT_DIR}/data/moves.yaml").to_h { |m| [m['id'].to_sym, m['id_number']] }
def pbLoadBattleAnimations = $test_anims
class PokeBattle_Scene
  def pbFindMoveAnimation(move, side, hit)
    num = $test_move_nums[move.to_sym]
    a = (side == 1 && $test_m2a[1][num]) || $test_m2a[0][num]
    a ? [a + hit, false] : nil
  end
end
