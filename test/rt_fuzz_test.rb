# Batalhas aleatórias (espécies, níveis, golpes e teclas sorteados) só para achar
# erros de execução e batalhas que nunca terminam.
# Uso: ruby test/rt_fuzz_test.rb [quantidade]
$fuzz = true
src = File.read(File.expand_path('rt_scene_test.rb', __dir__), encoding: 'UTF-8')
eval(src.split('#--- Cenários')[0], binding, File.expand_path('rt_scene_test.rb', __dir__))

def setup_world(party, balls)
  $game_map = MapStub.new; $game_player = PlayerStub.new(10, 8, [2, 4, 6, 8].sample)
  $game_system = SystemStub.new; $Trainer = TrainerStub.new(party); $PokemonBag = BagStub.new(balls)
  Graphics.frames = 0; Input.frame = 0; $messages = []
end

n = (ARGV[0] || 150).to_i
species = SPECIES.keys.select { |k| SPECIES[k]['id_number'].to_i.between?(1, 493) }
move_ids = MOVES.keys
keys = [:W, :A, :S, :D, :NUMBER_1, :NUMBER_2, :NUMBER_3, :NUMBER_4, :SPACE, :F, :Q]
results = Hash.new(0)
errors = 0
n.times do |i|
  rng = Random.new(i)
  RTB.rng_override = Random.new(i); srand(i)
  mk = -> { Pokemon.new(species.sample(random: rng).to_sym, rng.rand(2..60), move_ids.sample(4, random: rng)) }
  party = Array.new(rng.rand(1..3)) { mk.call }
  foe = mk.call
  setup_world(party, rng.rand(0..5))
  held = {}
  Input.script = lambda do |kind, k, f|
    if f % 20 == 0
      keys.each { |kk| held[kk] = rng.rand < 0.25 }
    end
    case kind
    when :pressex, :triggerex then held[k] && (kind == :pressex || f % 5 == 0)
    when :press then k == Input::BACK && f > 40 * 200   # depois de 200 s, foge
    else false
    end
  end
  begin
    d = RTB::Battle.new(foe, true).run
    results[d] += 1
  rescue StandardError => e
    errors += 1
    puts "ERRO na batalha #{i}: #{e.class}: #{e.message}"
    puts e.backtrace.first(4).map { |l| "    #{l}" }
  end
end
puts "decisões: #{results.sort.to_h}  erros: #{errors}"
exit(errors.zero? ? 0 : 1)
