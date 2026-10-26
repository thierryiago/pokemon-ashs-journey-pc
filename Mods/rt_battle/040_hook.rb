#==============================================================================
# Batalha em tempo real — gancho nas batalhas selvagens
#
# Troca a batalha por turno pela de tempo real quando der (um contra um, sem
# parceiro, em terra firme). Em qualquer outro caso, chama a versão original.
# O resultado devolvido é o mesmo do Essentials:
#   1 vitória, 2 derrota, 3 fuga, 4 captura.
#==============================================================================
module RTB
  module_function

  def wild_eligible?(args)
    return false unless defined?(AshJourney) && AshJourney::REALTIME_WILD_BATTLES
    return false if $PokemonSystem.respond_to?(:aj_battle_mode) && $PokemonSystem.aj_battle_mode != 0
    rules = $PokemonTemp.battleRules
    return false if rules["size"] && !["single", "1v1"].include?(rules["size"])
    return false if $PokemonGlobal.partner && !rules["noPartner"]
    return false if $PokemonGlobal.surfing || $PokemonGlobal.diving
    return false if $Trainer.able_pokemon_count == 0
    pokemon_count = args.count { |a| a.is_a?(Pokemon) || a.is_a?(Array) }
    species_count = args.count { |a| a.is_a?(Symbol) || a.is_a?(String) || a.is_a?(GameData::Species) }
    return false if pokemon_count + species_count != 1
    true
  rescue StandardError
    false
  end

  # Mesma regra do pbWildBattleCore para transformar os argumentos em Pokémon.
  def wild_from_args(args)
    a = args[0]
    return a if a.is_a?(Pokemon)
    if a.is_a?(Array)
      return pbGenerateWildPokemon(GameData::Species.get(a[0]).id, a[1])
    end
    pbGenerateWildPokemon(GameData::Species.get(args[0]).id, args[1])
  end
end

unless defined?(aj_turn_based_pbWildBattleCore)
  alias aj_turn_based_pbWildBattleCore pbWildBattleCore
end

def pbWildBattleCore(*args)
  return aj_turn_based_pbWildBattleCore(*args) unless RTB.wild_eligible?(args)
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  canRun     = !$PokemonTemp.battleRules["cannotRun"]
  Events.onStartBattle.trigger(nil)
  foe = RTB.wild_from_args(args)
  $PokemonTemp.clearBattleRules
  $game_temp.in_battle = true
  decision = 0
  begin
    decision = RTB::Battle.new(foe, canRun).run
  ensure
    $game_temp.in_battle = false
  end
  $PokemonGlobal.nextBattleBGM       = nil
  $PokemonGlobal.nextBattleME        = nil
  $PokemonGlobal.nextBattleCaptureME = nil
  $PokemonGlobal.nextBattleBack      = nil
  pbAfterBattle(decision, canLose)
  Input.update
  pbSet(outcomeVar, decision)
  decision
end
