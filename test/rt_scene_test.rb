# Roda a cena da batalha em tempo real fora do jogo, com dublês do RGSS e do
# Essentials. Não testa o visual: pega erros de nome, de tipo e de fluxo.
# Uso: ruby test/rt_scene_test.rb
require 'yaml'

#--- Dublês do RGSS -----------------------------------------------------------
class Color
  attr_accessor :red, :green, :blue, :alpha
  def initialize(r = 0, g = 0, b = 0, a = 255); @red, @green, @blue, @alpha = r, g, b, a; end
end
class Tone; def initialize(*a); end; end
class Rect
  attr_accessor :x, :y, :width, :height
  def initialize(x = 0, y = 0, w = 0, h = 0); set(x, y, w, h); end
  def set(x, y, w, h); @x, @y, @width, @height = x, y, w, h; end
end
class Font; attr_accessor :color, :size, :name, :bold; def initialize; @color = Color.new; end; end
class Bitmap
  attr_reader :width, :height, :font
  def initialize(w, h = nil); @width = w.is_a?(String) ? 128 : w; @height = h || 128; @font = Font.new; @disposed = false; end
  def fill_rect(*a); raise ArgumentError, "fill_rect args" unless [5, 2].include?(a.size); end
  def draw_text(*a); raise ArgumentError, "draw_text args" unless [5, 6, 2, 3].include?(a.size); end
  def blt(*a); end
  def clear; end
  def dispose; @disposed = true; end
  def disposed?; @disposed; end
end
class Viewport
  attr_accessor :z
  def initialize(*a); end
  def dispose; end
end
class Sprite
  attr_accessor :bitmap, :x, :y, :z, :ox, :oy, :zoom_x, :zoom_y, :angle, :opacity, :visible, :color, :tone
  attr_reader :src_rect
  def initialize(vp = nil); @src_rect = Rect.new; @opacity = 255; @zoom_x = @zoom_y = 1.0; @x = @y = 0; end
  def dispose; @disposed = true; end
  def disposed?; @disposed; end
end
module Graphics
  @frames = 0
  class << self; attr_accessor :frames; end
  def self.update; @frames += 1; raise 'travou: batalha passou de 5 minutos' if @frames > 40 * 300; end
  def self.frame_rate; 40; end
  def self.width; 512; end
  def self.height; 384; end
end
module Input
  LEFT = 4; RIGHT = 6; UP = 8; DOWN = 2; BACK = :B; USE = :C
  @script = nil
  class << self; attr_accessor :script, :frame; end
  def self.update; @frame = (@frame || 0) + 1; end
  def self.press?(k) = @script.call(:press, k, @frame)
  def self.pressex?(k) = @script.call(:pressex, k, @frame)
  def self.triggerex?(k) = @script.call(:triggerex, k, @frame)
end

#--- Dublês do Essentials ------------------------------------------------------
DATA_DIR = File.expand_path('../data', __dir__)
MOVES   = YAML.load_file("#{DATA_DIR}/moves.yaml").to_h { |m| [m['id'], m] }
SPECIES = YAML.load_file("#{DATA_DIR}/species.yaml").select { |s| s['form'].to_i == 0 }.to_h { |s| [s['id'], s] }
TYPES   = YAML.load_file("#{DATA_DIR}/types.yaml").to_h { |t| [t['id'], t] }

module Settings
  GAIN_EXP_FOR_CAPTURE = true
  SPLIT_EXP_BETWEEN_GAINERS = false
  SCALED_EXP_FORMULA = true
end
module Effectiveness
  NORMAL_EFFECTIVE = 8
  def self.calculate(atk, *defs)
    defs.compact.uniq.first(3).reduce(1) do |m, d|
      t = TYPES[d.to_s]
      m * if t['immunities'].include?(atk.to_s) then 0
          elsif t['weaknesses'].include?(atk.to_s) then 4
          elsif t['resistances'].include?(atk.to_s) then 1
          else 2 end
    end * (2**(3 - defs.compact.uniq.first(3).size))
  end
end
module GameData
  class Move
    attr_reader :id, :name, :type, :category, :base_damage, :function_code, :effect_chance, :target, :flags, :priority
    def self.get(id)
      m = MOVES[id.to_s]
      o = allocate
      o.instance_variable_set(:@id, id.to_sym); o.instance_variable_set(:@name, m['real_name'])
      o.instance_variable_set(:@type, m['type'].to_sym); o.instance_variable_set(:@category, m['category'])
      o.instance_variable_set(:@base_damage, m['base_damage']); o.instance_variable_set(:@function_code, m['function_code'])
      o.instance_variable_set(:@effect_chance, m['effect_chance']); o.instance_variable_set(:@target, m['target'].to_sym)
      o.instance_variable_set(:@flags, m['flags']); o.instance_variable_set(:@priority, m['priority'])
      o
    end
  end
  class Item; def self.exists?(id) = true; end
  class TerrainTag; def self.try_get(*) = nil; end
  class Species; def self.get(id) = Struct.new(:id).new(id.to_sym); end
end
class GrowthStub
  def maximum_exp = 1_000_000
  def add_exp(a, b) = a + b
end
class PkMove
  attr_accessor :id, :pp
  def initialize(id); @id = id; @pp = MOVES[id.to_s]['total_pp']; end
  def total_pp = MOVES[@id.to_s]['total_pp']
end
OwnerStub = Struct.new(:id)
class Pokemon
  EV_LIMIT = 510; EV_STAT_LIMIT = 252
  attr_accessor :name, :level, :hp, :totalhp, :attack, :defense, :spatk, :spdef, :speed, :moves, :status,
                :statusCount, :species, :form, :exp, :poke_ball, :ev, :owner
  def initialize(species, level, moves)
    @species = species; @level = level; @form = 0
    sd = SPECIES[species.to_s]; @name = sd['real_name']
    b = sd['base_stats']
    st = ->(k) { ((2 * b[k] + 15) * level / 100.0).floor + 5 }
    @totalhp = ((2 * b['HP'] + 15) * level / 100.0).floor + level + 10
    @hp = @totalhp
    @attack, @defense, @spatk, @spdef, @speed = st.('ATTACK'), st.('DEFENSE'), st.('SPECIAL_ATTACK'), st.('SPECIAL_DEFENSE'), st.('SPEED')
    @moves = moves.map { |m| PkMove.new(m) }
    @status = :NONE; @statusCount = 0; @exp = 100
    @ev = Hash.new(0); @owner = OwnerStub.new(1)
  end
  def types = [SPECIES[@species.to_s]['type1'], SPECIES[@species.to_s]['type2']].uniq.map(&:to_sym)
  def able? = @hp > 0
  def base_exp = SPECIES[@species.to_s]['base_exp']
  def growth_rate = GrowthStub.new
  def species_data = Struct.new(:catch_rate, :evs).new(SPECIES[@species.to_s]['catch_rate'], SPECIES[@species.to_s]['evs'].transform_keys(&:to_sym))
  def calc_stats; end
  def getMoveList = []
  def hasMove?(m) = @moves.any? { |x| x.id == m }
  def changeHappiness(*) ; end
  def mega? = false
  def makeUnmega; end
  def makeUnprimal; end
  def heal_status; @status = :NONE; end
  def record_first_moves; end
end
class Pokedex; def register(*); end; def set_owned(*); end; end
class TrainerStub
  attr_accessor :party, :name, :id, :has_pokedex
  def initialize(party); @party = party; @name = 'Ash'; @id = 1; @has_pokedex = true; end
  def pokedex = Pokedex.new
  def owned?(*) = false
end
class BagStub
  def initialize(n); @n = n; end
  def pbHasItem?(i) = i == :POKEBALL && @n > 0
  def pbDeleteItem(i); @n -= 1; end
end
class MapStub
  def display_x = 0
  def display_y = 0
  def width = 20
  def height = 15
end
class Game_Map; X_SUBPIXELS = 4; Y_SUBPIXELS = 4; end
PlayerStub = Struct.new(:x, :y, :direction)
class SystemStub; def getPlayingBGM = nil; def bgm_pause; end; def bgm_resume(*); end; end
module RPG; module Cache; def self.load_bitmap(*) = Bitmap.new(128, 128); end; end
def _INTL(s, *a) = a.each_with_index.reduce(s) { |r, (v, i)| r.gsub("{#{i + 1}}", v.to_s) }
def pbResolveBitmap(p) = p
def pbUpdateSceneMap; end
def pbBGMPlay(*); end
def pbMEPlay(*); end
def pbSEPlay(*); end
def pbGetWildBattleBGM(*) = nil
def pbGetWildVictoryME = nil
def pbSetSmallFont(*); end
$messages = []
def pbMessage(t) = $messages << t
def pbNickname(*); end
def pbStorePokemon(p) = $Trainer.party << p
def pbLearnMove(*); end

load File.expand_path('../Mods/rt_battle/010_moves.rb', __dir__)
load File.expand_path('../Mods/rt_battle/020_sim.rb', __dir__)
load File.expand_path('../Mods/rt_battle/030_scene.rb', __dir__)
module RTB
  def self.tile_walkable?(tx, ty) = !(tx == 8 && ty.between?(5, 7))   # uma "parede" no meio
end

#--- Cenários -----------------------------------------------------------------
def setup_world(party, balls)
  $game_map = MapStub.new
  $game_player = PlayerStub.new(10, 8, 8)
  $game_system = SystemStub.new
  $Trainer = TrainerStub.new(party)
  $PokemonBag = BagStub.new(balls)
  Graphics.frames = 0
  Input.frame = 0
  $messages = []
end

# Tecla de direção que leva o Pokémon do jogador até o inimigo.
def chase_key(b, k)
  me = b.instance_variable_get(:@mine); en = b.instance_variable_get(:@enemy)
  return false unless me && en
  dx = en.x - me.x; dy = en.y - me.y
  { A: dx < -20, D: dx > 20, W: dy < -20, S: dy > 20 }[k] || false
end

fails = 0
check = ->(cond, msg) { if cond then puts "ok   #{msg}" else fails += 1; puts "FALHA #{msg}" end }

# A) Jogador ataca sem parar andando na direção do inimigo: deve vencer
srand(3)
setup_world([Pokemon.new(:PIKACHU, 10, [:THUNDERSHOCK, :GROWL, :QUICKATTACK, :THUNDERWAVE])], 0)
foe = Pokemon.new(:RATTATA, 3, [:TACKLE, :TAILWHIP])
battle = RTB::Battle.new(foe, true)
Input.script = lambda do |kind, k, f|
  case kind
  when :pressex then chase_key(battle, k)          # anda na direção do selvagem
  when :triggerex then k == :NUMBER_1 && f % 10 == 0
  else false
  end
end
d = battle.run
check.(d == 1, "vitória atacando (decisão #{d}, #{Graphics.frames} quadros, Rattata #{foe.hp}/#{foe.totalhp})")
check.($messages.any? { |m| m.include?('EXP') }, "ganhou EXP: #{$messages.first}")

# B) Captura: Poké Bola sempre acerta; com várias bolas, uma hora captura
srand(5)
setup_world([Pokemon.new(:PIKACHU, 10, [:THUNDERSHOCK])], 30)
foe = Pokemon.new(:RATTATA, 3, [:TACKLE])
Input.script = ->(kind, k, f) { kind == :triggerex && k == :F && f % 60 == 0 }
d = RTB::Battle.new(foe, true).run
check.(d == 4 && $Trainer.party.include?(foe), "captura (decisão #{d}, party #{$Trainer.party.size})")

# C) Fuga segurando Esc
setup_world([Pokemon.new(:PIKACHU, 10, [:THUNDERSHOCK])], 0)
Input.script = ->(kind, k, f) { kind == :press && k == Input::BACK }
d = RTB::Battle.new(Pokemon.new(:RATTATA, 3, [:TACKLE]), true).run
check.(d == 3, "fuga (decisão #{d})")

# D) Fuga proibida + derrota: jogador parado, inimigo forte
setup_world([Pokemon.new(:CATERPIE, 3, [:TACKLE]), Pokemon.new(:WEEDLE, 3, [:POISONSTING])], 0)
Input.script = ->(kind, k, f) { kind == :press && k == Input::BACK }
d = RTB::Battle.new(Pokemon.new(:ONIX, 20, [:ROCKTHROW, :TACKLE]), false).run
check.(d == 2, "derrota com troca automática (decisão #{d}, #{$Trainer.party.map(&:hp).inspect})")

# E) Troca manual com Q, depois persegue o inimigo e ataca
setup_world([Pokemon.new(:PIKACHU, 10, [:THUNDERSHOCK]), Pokemon.new(:PIDGEY, 10, [:GUST])], 0)
b = RTB::Battle.new(Pokemon.new(:RATTATA, 4, [:TACKLE]), true)
Input.script = lambda do |kind, k, f|
  (kind == :triggerex && k == :Q && f == 30) || (kind == :triggerex && k == :NUMBER_1 && f % 8 == 0) ||
    (kind == :pressex && chase_key(b, k))
end
d = b.run
puts "  E: decisão #{d}, hp #{$Trainer.party.map(&:hp).inspect}, quadros #{Graphics.frames}"
check.(d == 1 && b.instance_variable_get(:@participants) == [0, 1], "troca com Q e vitória (participantes #{b.instance_variable_get(:@participants).inspect})")

puts fails.zero? ? "\nTUDO OK" : "\n#{fails} FALHA(S)"
exit(fails.zero? ? 0 : 1)
