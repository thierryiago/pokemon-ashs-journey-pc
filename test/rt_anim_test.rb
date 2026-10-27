# Batalhas com as animações reais do Fire Ash carregadas (Data/PkmnAnimations.rxdata),
# para exercitar o player de animações e os golpes que "caem no ponto".
# Uso: LANG=C.UTF-8 ruby test/rt_anim_test.rb
src = File.read(File.expand_path('rt_scene_test.rb', __dir__), encoding: 'UTF-8')
eval(src.split('#--- Cenários')[0], binding, File.expand_path('rt_scene_test.rb', __dir__))
require_relative 'support_anims'
class Sprite
  attr_accessor :mirror, :blend_type
  def color = (@color ||= ColorSet.new)
  def tone = (@tone ||= ColorSet.new)
  def color=(c); end
  def tone=(c); end
end
class ColorSet; def set(*a); raise ArgumentError, 'set' unless a.size == 4; end; end
class AnimatedBitmap; def initialize(*); end; def deanimate = Bitmap.new(960, 960); end
load File.expand_path('../Mods/rt_battle/035_move_anims.rb', __dir__)
$played = Hash.new(0)
class RTB::MoveAnimPlayer
  alias test_init initialize
  def initialize(info, *rest); $played[info[:anim].name] += 1; test_init(info, *rest); end
end
def setup_world(party, balls)
  $game_map = MapStub.new; $game_player = PlayerStub.new(10, 8, 8)
  $game_system = SystemStub.new; $Trainer = TrainerStub.new(party); $PokemonBag = BagStub.new(balls)
  Graphics.frames = 0; Input.frame = 0; $messages = []
  RTB.rng_override = Random.new(7); srand(7)
end
def chase_key(b, k)
  me = b.instance_variable_get(:@mine); en = b.instance_variable_get(:@enemy)
  return false unless me && en
  dx = en.x - me.x; dy = en.y - me.y
  { A: dx < -20, D: dx > 20, W: dy < -20, S: dy > 20 }[k] || false
end

fails = 0
check = ->(c, m) { if c then puts "ok   #{m}" else fails += 1; puts "FALHA #{m}" end }

spec = RTB.spec_for_move(PkMove.new(:THUNDERSHOCK), 0)
check.(spec.kind == :beam && spec.anim, "Thunder Shock sai em linha reta e acerta na hora, com animação (#{spec.kind})")
spec = RTB.spec_for_move(PkMove.new(:EMBER), 0)
check.(spec.kind == :projectile && spec.anim[:travel_pattern], 'Ember continua projétil, desenhado com a brasa da animação')
spec = RTB.spec_for_move(PkMove.new(:THUNDERWAVE), 1)
check.(spec.kind == :strike, 'Thunder Wave (status) cai de cima num ponto')

setup_world([Pokemon.new(:PIKACHU, 12, [:THUNDERSHOCK, :THUNDERWAVE, :QUICKATTACK, :GROWL])], 0)
b = RTB::Battle.new(Pokemon.new(:CHARMANDER, 6, [:EMBER, :SCRATCH, :GROWL]), true)
Input.script = lambda do |kind, k, f|
  (kind == :pressex && chase_key(b, k)) || (kind == :triggerex && [:NUMBER_1, :NUMBER_2, :NUMBER_3, :NUMBER_4][(f / 12) % 4] == k && f % 12 == 0)
end
d = b.run
check.([1, 2].include?(d), "batalha com animações terminou (decisão #{d}, #{Graphics.frames} quadros)")
puts "  animações tocadas: #{$played.sort_by { |k, v| -v }.map { |k, v| "#{k}=#{v}" }.join(', ')}"
check.($played.keys.any? { |n| n.include?('THUNDERSHOCK') }, 'animação do Thunder Shock tocou')
check.(RTB.time_scale == 1.0, 'nos testes a velocidade fica em 1,0 (sem o arquivo de configuração)')

puts fails.zero? ? "\nTUDO OK" : "\n#{fails} FALHA(S)"
exit(fails.zero? ? 0 : 1)
