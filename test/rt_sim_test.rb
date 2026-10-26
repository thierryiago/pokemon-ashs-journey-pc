# Teste da simulação da batalha em tempo real, fora do jogo (Ruby puro).
# Uso: ruby test/rt_sim_test.rb
require 'yaml'
load File.expand_path('../Mods/rt_battle/010_moves.rb', __dir__)
load File.expand_path('../Mods/rt_battle/020_sim.rb', __dir__)

MOVES = YAML.load_file(File.expand_path('../data/moves.yaml', __dir__)).to_h { |m| [m['id'], m] }
TYPES = YAML.load_file(File.expand_path('../data/types.yaml', __dir__)).to_h { |t| [t['id'], t] }

def type_mult(atk, defs)
  defs.uniq.reduce(1.0) do |m, d|
    t = TYPES[d.to_s]
    m * if t['immunities'].include?(atk.to_s) then 0.0
        elsif t['weaknesses'].include?(atk.to_s) then 2.0
        elsif t['resistances'].include?(atk.to_s) then 0.5
        else 1.0 end
  end
end

def spec_for(id)
  m = MOVES[id.to_s]
  RTB.classify(id: m['id'].to_sym, name: m['real_name'], type: m['type'].to_sym, category: m['category'],
               power: m['base_damage'], function_code: m['function_code'], effect_chance: m['effect_chance'],
               target: m['target'], flags: m['flags'], priority: m['priority'])
end

MoveStub = Struct.new(:id, :pp)
class PkmnStub
  attr_accessor :name, :level, :hp, :totalhp, :attack, :defense, :spatk, :spdef, :speed, :types, :moves, :status, :statusCount
  def initialize(name, level, types, stats, moves)
    @name = name; @level = level; @types = types
    @totalhp, @attack, @defense, @spatk, @spdef, @speed = stats
    @hp = @totalhp; @status = :NONE; @statusCount = 0
    @moves = moves.map { |m| MoveStub.new(m, MOVES[m.to_s]['total_pp']) }
  end
end

fails = 0
check = ->(cond, msg) { if cond then puts "ok   #{msg}" else fails += 1; puts "FALHA #{msg}" end }

# 1) Classificação de golpes conhecidos
{ TACKLE: :melee, QUICKATTACK: :dash, THUNDERSHOCK: :projectile, EMBER: :projectile,
  ICEBEAM: :beam, SOLARBEAM: :beam, EARTHQUAKE: :pulse, GROWL: :debuff, TAILWHIP: :debuff,
  THUNDERWAVE: :status, SWORDSDANCE: :buff, RECOVER: :buff, SPIKES: :noop, RAINDANCE: :noop,
  FLAMETHROWER: :projectile, TAKEDOWN: :dash, HYPERVOICE: :pulse }.each do |id, kind|
  s = spec_for(id)
  check.(s.kind == kind, "#{id} -> #{kind} (veio #{s.kind}, recarga #{s.cooldown}s)")
end

# 2) Classificação de todos os golpes sem erro
counts = Hash.new(0)
MOVES.each_key { |id| counts[spec_for(id).kind] += 1 }
puts "famílias: #{counts.sort_by { |k, v| -v }.map { |k, v| "#{k}=#{v}" }.join(' ')}"
check.(counts.values.sum == MOVES.size, "todos os #{MOVES.size} golpes classificados")

# 3) Batalhas completas IA x IA terminam, sem NaN, em tempo razoável
def battle(seed, a, b, ai_level = 1)
  rng = Random.new(seed)
  sim = RTB::Sim.new(arena: [0, 0, 416, 288], walkable: ->(x, y) { !(x.between?(192, 224) && y.between?(96, 160)) },
                     type_mult: method(:type_mult), rng: rng, ai_level: ai_level)
  fa = sim.add(RTB::Fighter.new(a, 0, a.moves.map { |m| spec_for(m.id) }, 100, 200))
  fb = sim.add(RTB::Fighter.new(b, 1, b.moves.map { |m| spec_for(m.id) }, 300, 90))
  t = 0
  until fa.fainted? || fb.fainted? || t > 240
    sim.update(1.0 / 40, {})   # os dois lados na IA
    t += 1.0 / 40
    [fa, fb].each { |f| raise "NaN" if f.x.nan? || f.y.nan? }
  end
  [t, fa, fb, sim]
end

times = []
20.times do |seed|
  pika = PkmnStub.new('Pikachu', 8, [:ELECTRIC], [26, 14, 10, 13, 12, 20], [:THUNDERSHOCK, :GROWL, :QUICKATTACK, :THUNDERWAVE])
  ratt = PkmnStub.new('Rattata', 4, [:NORMAL], [17, 10, 8, 6, 7, 12], [:TACKLE, :TAILWHIP])
  t, fa, fb, = battle(seed, pika, ratt)
  times << t
  check.(fa.fainted? || fb.fainted?, format('seed %2d: terminou em %5.1fs, Pikachu %d/%d, Rattata %d/%d', seed, t, fa.hp, fa.totalhp, fb.hp, fb.totalhp))
end
puts format('duração média %.1fs', times.sum / times.size)

# 4) Golpes com efeito: sono para o alvo, cura recupera, tipo imune não toma dano
s = RTB::Sim.new(arena: [0, 0, 400, 400], walkable: ->(x, y) { true }, type_mult: method(:type_mult), rng: Random.new(1))
geo = PkmnStub.new('Geodude', 10, [:ROCK, :GROUND], [30, 20, 25, 8, 8, 6], [:TACKLE])
pk  = PkmnStub.new('Pikachu', 10, [:ELECTRIC], [30, 15, 10, 14, 12, 22], [:THUNDERSHOCK])
fp = s.add(RTB::Fighter.new(pk, 0, [spec_for(:THUNDERSHOCK)], 100, 100))
fg = s.add(RTB::Fighter.new(geo, 1, [spec_for(:TACKLE)], 200, 100))
s.hit(fp, fg, spec_for(:THUNDERSHOCK))
check.(geo.hp == geo.totalhp, 'Thunder Shock não afeta Geodude (imune)')
s.set_status(fg, :SLEEP, spec_for(:SLEEPPOWDER))
check.(fg.stun > 2 && geo.status == :SLEEP, 'sono deixa o alvo parado')
geo.hp = 10
s.apply_self_effect(fg, spec_for(:RECOVER))
check.(geo.hp == 25, "Recover cura metade (hp #{geo.hp})")

puts fails.zero? ? "\nTUDO OK" : "\n#{fails} FALHA(S)"
exit(fails.zero? ? 0 : 1)
