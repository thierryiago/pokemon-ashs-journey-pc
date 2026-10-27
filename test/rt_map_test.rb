# Física do mapa da batalha em tempo real (Mods/rt_battle/025_map.rb) com um
# mapa de mentira: parede, cerca que bloqueia só um lado, barranco, água e eventos.
# Uso: ruby test/rt_map_test.rb
fails = 0
check = lambda do |ok, msg|
  puts "#{ok ? 'ok  ' : 'FALHA'} #{msg}"
  fails += 1 unless ok
end

module GameData
  class TerrainTag
    Tag = Struct.new(:can_surf, :ledge, :ignore_passability, :bridge)
    TAGS = { 0 => Tag.new(false, false, false, false), 1 => Tag.new(false, true, false, false),  # 1 barranco
             7 => Tag.new(true, false, false, false), 15 => Tag.new(false, false, false, true) } # 7 água, 15 ponte
    def self.try_get(id) = TAGS[id] || TAGS[0]
  end
end

class Table3
  def initialize = @h = Hash.new(0)
  def [](x, y, z) = @h[[x, y, z]]
  def []=(x, y, z, v)
    @h[[x, y, z]] = v
  end
end

Ev = Struct.new(:x, :y, :through, :erased, :character_name, :tile_id)

class FakeMap
  attr_reader :data, :passages, :priorities, :terrain_tags, :events
  def initialize
    @data = Table3.new
    @passages = Hash.new(0); @priorities = Hash.new(0); @terrain_tags = Hash.new(0)
    # tiles: 384 chão, 385 parede cheia, 386 cerca (bloqueia baixo), 387 barranco, 388 água,
    #        389 copa de árvore (prioridade alta, sem bloqueio)
    @passages[385] = 0x0f
    @passages[386] = 0x01
    @terrain_tags[387] = 1
    @terrain_tags[388] = 7
    @priorities[389] = 1
    @passages[390] = 0x06; @terrain_tags[390] = 15   # ponte: bloqueia os lados (esquerda/direita)
    (0...10).each { |x| (0...10).each { |y| @data[x, y, 0] = 384 } }
    @data[2, 2, 1] = 385
    @data[3, 3, 1] = 386
    @data[4, 4, 0] = 387
    @data[5, 5, 0] = 388
    @data[6, 6, 2] = 389
    @data[9, 2, 0] = 388; @data[9, 2, 2] = 390     # ponte sobre a água
    @events = { 1 => Ev.new(7, 7, false, false, "boulder", 0),
                2 => Ev.new(8, 8, true, false, "npc", 0),     # atravessável
                3 => Ev.new(1, 8, false, false, "", 0) }      # evento invisível
  end
  def valid?(x, y) = x.between?(0, 9) && y.between?(0, 9)
end

$game_map = FakeMap.new
$game_player = Struct.new(:x, :y).new(0, 0)
load File.expand_path('../Mods/rt_battle/025_map.rb', __dir__)

check.(RTB.tile_walkable?(1, 1), 'chão: dá para andar')
check.(!RTB.tile_walkable?(2, 2) && !RTB.tile_flyable?(2, 2), 'parede: não anda e golpe não passa')
check.(RTB.tile_walkable?(3, 3), 'tile da cerca: dá para ficar em cima')
check.(!RTB.tiles_crossable?(3, 3, 3, 4), 'cerca: não sai pelo lado de baixo')
check.(!RTB.tiles_crossable?(3, 4, 3, 3), 'cerca: não entra vindo de baixo')
check.(RTB.tiles_crossable?(3, 3, 4, 3) && RTB.tiles_crossable?(3, 2, 3, 3), 'cerca: os outros lados ficam livres')
check.(!RTB.tile_walkable?(4, 4), 'barranco: Pokémon não pula durante a luta')
check.(RTB.tile_flyable?(4, 4), 'barranco: golpe passa por cima')
check.(!RTB.tile_walkable?(5, 5) && RTB.tile_flyable?(5, 5), 'água: não anda, golpe passa')
check.(RTB.tile_walkable?(6, 6), 'copa de árvore por cima: chão embaixo continua livre')
check.(!RTB.tile_walkable?(10, 0), 'fora do mapa')
$PokemonGlobal = Struct.new(:bridge).new(0)
check.(!RTB.tile_walkable?(9, 2), 'debaixo da ponte (fora dela): água, não anda')
$PokemonGlobal.bridge = 1
check.(RTB.tile_walkable?(9, 2), 'em cima da ponte: anda')
check.(!RTB.tiles_crossable?(9, 2, 8, 2) && RTB.tiles_crossable?(9, 2, 9, 3), 'em cima da ponte: não cai pelos lados')
$PokemonGlobal.bridge = 0
solid = RTB.solid_event_tiles
check.(solid[[7, 7]], 'evento sólido (pedra) bloqueia')
check.(!solid[[8, 8]] && !solid[[1, 8]], 'evento atravessável ou invisível não bloqueia')
check.(solid[[0, 0]], 'o jogador (parado) bloqueia o tile dele')

puts fails.zero? ? "\nTUDO OK" : "\n#{fails} FALHA(S)"
exit(fails.zero? ? 0 : 1)
