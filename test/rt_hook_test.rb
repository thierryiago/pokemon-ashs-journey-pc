# Testa o gancho (040_hook.rb): quando a batalha vira tempo real e quais regras passam adiante.
# Uso: ruby test/rt_hook_test.rb
module AshJourney; REALTIME_WILD_BATTLES = true; end
class Pokemon; end
module GameData; class Species; end; end
class NPCTrainer; end
TempStub = Struct.new(:battleRules) do
  def clearBattleRules; self.battleRules = {}; end
end
GlobalStub = Struct.new(:partner, :surfing, :diving, :nextBattleBGM, :nextBattleME, :nextBattleCaptureME, :nextBattleBack)
SystemStub = Struct.new(:aj_battle_mode, :aj_trainer_mode)
$calls = []
def pbWildBattleCore(*args); $calls << [:turnos, args]; 1; end
def pbTrainerBattleCore(*args); $calls << [:turnos_treinador, args]; 1; end
def pbGenerateWildPokemon(sp, lv) = [:wild, sp, lv]
module Events; def self.onStartBattle = Struct.new(:x) { def trigger(*); end }.new(nil); end
def pbAfterBattle(*); end
def pbSet(*); end
module Input; def self.update; end; end
GameTempStub = Struct.new(:in_battle)
$game_temp = GameTempStub.new(false)
$game_switches = []
class TrainerStub; def able_pokemon_count = 1; end
$Trainer = TrainerStub.new
module RTB
  class Battle
    def initialize(*a, **k); $calls << [:tempo_real, a, k]; end
    def run = 1
  end
end
module GameData; class Species; def self.get(s) = Struct.new(:id).new(s); end; end
load File.expand_path('../Mods/rt_battle/040_hook.rb', __dir__)

fails = 0
check = ->(c, m) { if c then puts "ok   #{m}" else fails += 1; puts "FALHA #{m}" end }
reset = lambda do |rules = {}, mode: 0|
  $PokemonTemp = TempStub.new(rules); $PokemonGlobal = GlobalStub.new
  $PokemonSystem = SystemStub.new(mode, 1); $calls = []
end

reset.call
pbWildBattleCore(:RATTATA, 3)
check.($calls.last[0] == :tempo_real, 'selvagem comum vira tempo real')
reset.call({ 'canRun' => false, 'outcomeVar' => 5 })
pbWildBattleCore(:SNORLAX, 30)
check.($calls.last[0] == :tempo_real && $calls.last[1][1] == false, "evento sem fuga passa canRun=false (#{$calls.last[1].inspect})")
reset.call({ 'size' => 'double' })
pbWildBattleCore(:RATTATA, 3, :PIDGEY, 3)
check.($calls.last[0] == :turnos, 'dupla continua por turno')
reset.call({ 'itemLimit' => 2 })
pbWildBattleCore(:RATTATA, 3)
check.($calls.last[0] == :turnos, 'regra desconhecida (limite de itens) continua por turno')
reset.call({}, mode: 1)
pbWildBattleCore(:RATTATA, 3)
check.($calls.last[0] == :turnos, 'opção "Turnos" no menu respeitada')
reset.call
$game_switches[494] = true
module Settings; MAXRAID_SWITCH = 494; end
pbWildBattleCore(:RATTATA, 3)
check.($calls.last[0] == :turnos, 'Max Raid continua por turno')
$game_switches[494] = false
reset.call
$PokemonGlobal.surfing = true
pbWildBattleCore(:TENTACOOL, 20)
check.($calls.last[0] == :turnos, 'surfando continua por turno')
reset.call({ 'expGain' => false })
pbWildBattleCore(:RATTATA, 3)
check.($calls.last[0] == :tempo_real && $calls.last[2][:exp_gain] == false, 'sem EXP passa exp_gain=false')
reset.call
pbTrainerBattleCore(NPCTrainer.new)
check.($calls.last[0] == :turnos_treinador || $calls.last[0] == :tempo_real, 'treinador não quebra')

puts fails.zero? ? "\nTUDO OK" : "\n#{fails} FALHA(S)"
exit(fails.zero? ? 0 : 1)
