# Teste da simulação da batalha em tempo real, fora do jogo (Ruby puro).
# Uso: ruby test/rt_sim_test.rb
require 'yaml'
load File.expand_path('../Mods/rt_battle/010_moves.rb', __dir__)
load File.expand_path('../Mods/rt_battle/020_sim.rb', __dir__)
load File.expand_path('../Mods/rt_battle/021_sim_effects.rb', __dir__)

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
  THUNDERWAVE: :status, SWORDSDANCE: :buff, RECOVER: :buff, SPIKES: :hazard, RAINDANCE: :buff, FLY: :strike, DIG: :strike, PROTECT: :buff,
  SUBSTITUTE: :buff, METRONOME: :buff, TAUNT: :status, PERISHSONG: :buff,
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

# 5) Física: cerca entre duas linhas de tiles (só um lado do tile), projétil passa por cima
fence = ->(x1, y1, x2, y2) { !(x1 == x2 && x1 <= 3 && [y1, y2].sort == [4, 5]) }  # aberta em x >= 4
s = RTB::Sim.new(arena: [0, 0, 416, 288], walkable: ->(x, y) { true }, crossable: fence,
                 type_mult: method(:type_mult), rng: Random.new(2))
a1 = PkmnStub.new('Rattata', 10, [:NORMAL], [30, 15, 10, 14, 12, 22], [:TACKLE])
b1 = PkmnStub.new('Rattata', 10, [:NORMAL], [30, 15, 10, 14, 12, 22], [:TACKLE])
fa = s.add(RTB::Fighter.new(a1, 0, [spec_for(:TACKLE)], 60, 120))
fb = s.add(RTB::Fighter.new(b1, 1, [spec_for(:TACKLE)], 390, 30))
still = { mx: 0.0, my: 0.0 }
80.times { s.update(1.0 / 40, { 0 => { mx: 0.0, my: 1.0 }, 1 => still }) }
check.(fa.y < 160, format('cerca segura quem anda contra ela (y = %.1f)', fa.y))
s.update(1.0 / 40, { 0 => { mx: 1.0, my: 0.0 }, 1 => still }) until fa.x > 150
80.times { s.update(1.0 / 40, { 0 => { mx: 0.0, my: 1.0 }, 1 => still }) }
check.(fa.y > 160, format('passa pela abertura da cerca (x = %.1f, y = %.1f)', fa.x, fa.y))
check.(s.line_clear?(60, 120, 60, 220) == false, 'IA enxerga a cerca no caminho')
check.(s.line_clear?(200, 120, 200, 220), 'sem cerca, caminho livre')
check.(s.bfs_next(48, 144, 48, 176) == [2, 4], "caminho da IA contorna a cerca (#{s.bfs_next(48, 144, 48, 176).inspect})")

# 6) Feixe para na parede
s = RTB::Sim.new(arena: [0, 0, 416, 288], walkable: ->(x, y) { !x.between?(160, 191) },
                 type_mult: method(:type_mult), rng: Random.new(3))
check.(s.ray_length(100, 100, 1.0, 0.0, 260) < 70, 'feixe para na parede')
check.(s.ray_length(100, 100, 0.0, 1.0, 150) == 150, 'feixe sem parede vai até o fim')

# 7) Efeitos dos golpes (B2)
def duel(a_moves, b_moves, seed: 5, **opts)
  s = RTB::Sim.new(arena: [0, 0, 416, 288], walkable: ->(x, y) { true }, type_mult: method(:type_mult),
                   rng: Random.new(seed), **opts)
  a = PkmnStub.new('Ataca', 30, [:NORMAL], [90, 60, 50, 60, 50, 60], a_moves)
  b = PkmnStub.new('Alvo', 30, [:NORMAL], [90, 60, 50, 60, 50, 60], b_moves)
  fa = s.add(RTB::Fighter.new(a, 0, a_moves.map { |m| spec_for(m) }, 100, 100))
  fb = s.add(RTB::Fighter.new(b, 1, b_moves.map { |m| spec_for(m) }, 140, 100))
  fa.fx, fa.fy = 1.0, 0.0
  [s, fa, fb]
end
idle = { mx: 0.0, my: 0.0 }
use = ->(s, slot, t = 1.5) { s.update(0.02, { 0 => { mx: 0.0, my: 0.0, use: slot }, 1 => idle }); ((t / 0.02).to_i).times { s.update(0.02, { 0 => idle, 1 => idle }) } }

s, fa, fb = duel([:RAINDANCE, :WATERGUN], [:TACKLE])
use.(s, 0)
check.(s.weather == :RAIN, 'Rain Dance liga a chuva')
w = spec_for(:WATERGUN)
check.(s.field_mult(fa, fb, w, false, false) == 1.5, 'chuva fortalece golpes de água')
s, fa, fb = duel([:SANDSTORM], [:TACKLE])
use.(s, 0, 4)
check.(fb.hp < fb.totalhp && fa.hp < fa.totalhp, "tempestade de areia machuca quem não é Pedra/Terra/Aço (#{fb.hp}/#{fb.totalhp})")

s, fa, fb = duel([:REFLECT], [:TACKLE])
use.(s, 0)
check.(s.side_fx[0][:reflect] > 0 && s.field_mult(fb, fa, spec_for(:TACKLE), true, false) == 0.5, 'Reflect corta dano físico pela metade')

s, fa, fb = duel([:SUBSTITUTE], [:TACKLE, :THUNDERWAVE])
use.(s, 0)
check.(fa.sub_hp > 0 && fa.hp == fa.totalhp - fa.totalhp / 4, 'Substitute custa 1/4 da vida e cria o substituto')
hp = fa.hp
s.hit(fb, fa, spec_for(:THUNDERWAVE))
check.(fa.status == :NONE, 'substituto bloqueia golpe de status')
s.hit(fb, fa, spec_for(:TACKLE))
check.(fa.hp == hp, 'substituto toma o dano no lugar')

s, fa, fb = duel([:SPIKES], [:TACKLE])
fb.x, fb.y = 390, 260
use.(s, 0, 0.5)
check.(s.hazards.length == 3, "Spikes espalha 3 pontas no chão (#{s.hazards.length})")
hz = s.hazards.first
fb.x, fb.y = hz.x, hz.y
s.update(0.02, { 0 => idle, 1 => idle })
check.(fb.hp == fb.totalhp - fb.totalhp / 8, "pisar numa ponta tira 1/8 da vida (#{fb.hp}/#{fb.totalhp})")
fa.x, fa.y = s.hazards.first.x, s.hazards.first.y
hpa = fa.hp
s.update(0.02, { 0 => idle, 1 => idle })
check.(fa.hp == hpa, 'quem jogou as pontas não se machuca nelas')

s, fa, fb = duel([:DIG], [:TACKLE, :EARTHQUAKE])
s.update(0.02, { 0 => { mx: 0, my: 0, use: 0 }, 1 => idle })
check.(fa.semi == :dig, 'Dig: some debaixo da terra durante a preparação')
s.hit(fb, fa, spec_for(:TACKLE))
check.(fa.hp == fa.totalhp, 'Tackle não alcança quem está debaixo da terra')
s.hit(fb, fa, spec_for(:EARTHQUAKE))
check.(fa.hp < fa.totalhp, 'Earthquake alcança quem cavou')
50.times { s.update(0.02, { 0 => idle, 1 => idle }) }
check.(fa.semi.nil? && fb.hp < fb.totalhp, 'Dig sai do chão em cima do alvo')

s, fa, fb = duel([:TACKLE], [:SOLARBEAM])
s.update(0.02, { 0 => idle, 1 => { mx: 0, my: 0, use: 0 } })
check.(fb.pending, 'Solar Beam carregando')
s.instance_variable_get(:@rng).define_singleton_method(:rand) { |*a| a.empty? ? 0.0 : 0 }
s.hit(fa, fb, spec_for(:HEADBUTT))
check.(fb.pending.nil?, 'recuo (Headbutt) interrompe o golpe que o alvo preparava')

s, fa, fb = duel([:WRAP], [:TACKLE])
s.hit(fa, fb, spec_for(:WRAP))
x0 = fb.x
s.update(0.5, { 0 => idle, 1 => { mx: 1.0, my: 0.0 } })
check.(fb.timers[:bound] > 0 && fb.x == x0, 'Wrap prende o alvo no lugar')
check.(!s.can_escape?(fb), 'preso não foge')

s, fa, fb = duel([:COUNTER], [:TACKLE])
s.hit(fb, fa, spec_for(:TACKLE))
taken = fa.totalhp - fa.hp
s.hit(fa, fb, spec_for(:COUNTER))
check.(fb.totalhp - fb.hp == taken * 2, "Counter devolve o dobro do dano físico recebido (#{taken} -> #{fb.totalhp - fb.hp})")

s, fa, fb = duel([:FALSESWIPE], [:TACKLE])
fb.pkmn.hp = 3
s.hit(fa, fb, spec_for(:FALSESWIPE))
check.(fb.hp == 1, 'False Swipe deixa com 1 PV (bom para capturar)')

s, fa, fb = duel([:FISSURE], [:TACKLE])
s.hit(fa, fb, spec_for(:FISSURE))
check.(fb.fainted?, 'Fissure nocauteia num golpe quem tem nível igual ou menor')

s, fa, fb = duel([:METRONOME], [:TACKLE], random_spec: ->(side) { spec_for(:EMBER) })
use.(s, 0, 1.0)
check.(s.events.any? { |e| e[0] == :text && e[2].to_s.include?('Ember') }, 'Metronome usa um golpe sorteado')

s, fa, fb = duel([:SLEEPTALK, :TACKLE], [:TACKLE])
fa.pkmn.status = :SLEEP; fa.stun = 3.0
s.update(0.02, { 0 => { mx: 0, my: 0, use: 0 }, 1 => idle })
check.(fa.pending || fa.cds[0] > 0, 'Sleep Talk funciona dormindo')

s, fa, fb = duel([:PROTECT], [:TACKLE, :FEINT])
use.(s, 0, 0.35)
s.hit(fb, fa, spec_for(:TACKLE))
check.(fa.hp == fa.totalhp, 'Protect bloqueia')
s.hit(fb, fa, spec_for(:FEINT))
check.(fa.hp < fa.totalhp, 'Feint atravessa o Protect')

s, fa, fb = duel([:TAUNT], [:SWORDSDANCE, :TACKLE])
s.hit(fa, fb, spec_for(:TAUNT))
s.update(0.02, { 0 => idle, 1 => { mx: 0, my: 0, use: 0 } })
check.(fb.stages[:atk] == 0 && fb.pending.nil?, 'provocado não usa golpe de status')

s, fa, fb = duel([:TACKLE], [:TACKLE, :GROWL])
s.update(0.02, { 0 => idle, 1 => { mx: 0, my: 0, use: 1 } })
s.hit(fa, fb, spec_for(:DISABLE))
check.(fb.cds[1] >= 5, 'Disable bloqueia o último golpe do alvo')

s, fa, fb = duel([:PERISHSONG], [:TACKLE])
use.(s, 0, 10)
check.(fa.fainted? && fb.fainted?, 'Perish Song derruba os dois depois de 9 s')

s, fa, fb = duel([:HEALINGWISH], [:TACKLE])
use.(s, 0, 0.5)
check.(fa.fainted?, 'Healing Wish: quem usa desmaia')
c = PkmnStub.new('Reserva', 30, [:NORMAL], [90, 60, 50, 60, 50, 60], [:TACKLE]); c.hp = 10; c.status = :POISON
fc = s.add(RTB::Fighter.new(c, 0, [spec_for(:TACKLE)], 100, 100))
check.(fc.hp == fc.totalhp && c.status == :NONE, 'quem entra depois chega curado')

s, fa, fb = duel([:SWIFT], [:TACKLE])
fa.fx, fa.fy = 0.0, -1.0   # olhando para longe do alvo
fb.x, fb.y = 260, 60
use.(s, 0, 1.0)
check.(fb.hp < fb.totalhp, 'Swift (sempre acerta) persegue o alvo')

s, fa, fb = duel([:HYPERBEAM], [:TACKLE])
fb.x = 200
use.(s, 0, 0.5)
check.(fa.stun > 0, 'Hyper Beam: precisa recarregar depois')

s, fa, fb = duel([:BELLYDRUM], [:TACKLE])
use.(s, 0, 0.5)
check.(fa.stages[:atk] == 6 && fa.hp == fa.totalhp - fa.totalhp / 2, 'Belly Drum: metade da vida por Ataque no máximo')

s, fa, fb = duel([:UTURN], [:TACKLE])
s.hit(fa, fb, spec_for(:UTURN))
check.(s.events.any? { |e| e[0] == :switch_out && e[1] == fa }, 'U-turn pede a troca depois de acertar')

n = 0
40.times do |i|
  s, fa, fb = duel([:METALCLAW], [:TACKLE], seed: i)
  s.hit(fa, fb, spec_for(:METALCLAW))
  n += 1 if fa.stages[:atk] > 0
end
check.(n.between?(1, 12), "Metal Claw só sobe Ataque às vezes (10%): #{n}/40")
s, fa, fb = duel([:CLOSECOMBAT], [:TACKLE])
s.hit(fa, fb, spec_for(:CLOSECOMBAT))
check.(fa.stages[:def] == -1 && fa.stages[:spd] == -1, 'Close Combat sempre baixa as defesas de quem usa')

s, fa, fb = duel([:TACKLE], [:SPLASH])
check.(s.ai_score(fb, fa, spec_for(:SPLASH)) > 0, 'Magikarp ainda usa Splash')
check.(s.ai_score(fb, fa, spec_for(:EXPLOSION)) < 20, 'IA não explode com a vida cheia')

puts fails.zero? ? "\nTUDO OK" : "\n#{fails} FALHA(S)"
exit(fails.zero? ? 0 : 1)
