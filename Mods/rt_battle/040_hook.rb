#==============================================================================
# Batalha em tempo real — gancho nas batalhas selvagens
#
# Troca a batalha por turno pela de tempo real quando der (um contra um, sem
# parceiro, em terra firme). Em qualquer outro caso, chama a versão original.
# O resultado devolvido é o mesmo do Essentials:
#   1 vitória, 2 derrota, 3 fuga, 4 captura.
#==============================================================================
module RTB
  ERROR_LOG = "Mods/rt_battle_erros.txt"

  # Registra o erro num arquivo de texto (para mandar ao desenvolvimento) e avisa o jogador.
  def self.report_failure(e)
    File.open(ERROR_LOG, "a") do |f|
      f.puts "#{Time.now} #{e.class}: #{e.message}"
      (e.backtrace || []).first(12).each { |l| f.puts "    #{l}" }
      f.puts
    end
  rescue StandardError
    nil
  ensure
    pbMessage(_INTL("A batalha em tempo real deu erro e vai continuar por turno. Detalhes em {1}.", ERROR_LOG)) rescue nil
  end

  # Regras de batalha que a versão em tempo real entende. Qualquer outra
  # (limite de itens, efeito de campo...) mantém a batalha por turno.
  SUPPORTED_RULES = %w[size outcomeVar canLose canRun noPartner roamerFlees expGain moneyGain
                       environment backdrop base defaultWeather defaultTerrain switchStyle battleAnims]

  module_function

  def rules_supported?
    rules = $PokemonTemp.battleRules
    return false if rules["size"] && !["single", "1v1"].include?(rules["size"])
    return false if $PokemonGlobal.partner && !rules["noPartner"]
    (rules.keys - SUPPORTED_RULES).empty?
  end

  # Max Raids (plugin ZUD) ficam por turno (R4).
  def max_raid?
    defined?(Settings::MAXRAID_SWITCH) && $game_switches[Settings::MAXRAID_SWITCH]
  end

  # Algum arquivo de Mods/ falhou ao carregar? Então tudo fica por turno.
  def mods_ok?
    !defined?(AJMods) || !AJMods.respond_to?(:ok?) || AJMods.ok?
  end

  def wild_eligible?(args)
    return false unless defined?(AshJourney) && AshJourney::REALTIME_WILD_BATTLES
    return false unless mods_ok?
    return false if $PokemonSystem.respond_to?(:aj_battle_mode) && $PokemonSystem.aj_battle_mode != 0
    return false unless rules_supported?
    return false if max_raid?
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
  canRun     = $PokemonTemp.battleRules["canRun"] != false
  expGain    = $PokemonTemp.battleRules["expGain"] != false
  Events.onStartBattle.trigger(nil)
  foe = RTB.wild_from_args(args)
  $PokemonTemp.clearBattleRules
  $game_temp.in_battle = true
  decision = 0
  begin
    decision = RTB::Battle.new(foe, canRun, can_lose: canLose, exp_gain: expGain).run
  rescue StandardError => e
    $game_temp.in_battle = false
    RTB.report_failure(e)
    setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
    setBattleRule("canLose") if canLose
    setBattleRule("cannotRun") if !canRun
    setBattleRule("noexp") if !expGain
    return aj_turn_based_pbWildBattleCore(foe)
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

#------------------------------------------------------------------------------
# Batalhas de treinador (um treinador, um contra um). Ligadas pela opção
# "Batalha de treinador: Tempo real"; o padrão continua por turno até o teste.
#------------------------------------------------------------------------------
module RTB
  GRANDEUR_CLUB_MAPS = [141, 151, 214]

  module_function

  def trainer_eligible?(args)
    return false unless defined?(AshJourney) && AshJourney::REALTIME_WILD_BATTLES
    return false unless mods_ok?
    return false unless $PokemonSystem.respond_to?(:aj_trainer_mode) && $PokemonSystem.aj_trainer_mode == 1
    return false if args.length != 1
    return false unless rules_supported?
    return false if max_raid?
    return false if $PokemonGlobal.surfing || $PokemonGlobal.diving
    return false if GRANDEUR_CLUB_MAPS.include?($game_map.map_id)
    return false if $Trainer.able_pokemon_count == 0
    true
  rescue StandardError
    false
  end
end

unless defined?(aj_turn_based_pbTrainerBattleCore)
  alias aj_turn_based_pbTrainerBattleCore pbTrainerBattleCore
end

def pbTrainerBattleCore(*args)
  return aj_turn_based_pbTrainerBattleCore(*args) unless RTB.trainer_eligible?(args)
  arg = args[0]
  if arg.is_a?(NPCTrainer)
    trainer = arg
  elsif arg.is_a?(Array)
    trainer = pbLoadTrainer(arg[0], arg[1], arg[2])
    pbMissingTrainer(arg[0], arg[1], arg[2]) if !trainer
    return 0 if !trainer
    Events.onTrainerPartyLoad.trigger(nil, trainer)
    trainer.lose_text = arg[3] if arg[3] && !arg[3].to_s.empty?
  else
    return aj_turn_based_pbTrainerBattleCore(*args)
  end
  return aj_turn_based_pbTrainerBattleCore(trainer) if trainer.party.none? { |p| p.able? }
  outcomeVar = $PokemonTemp.battleRules["outcomeVar"] || 1
  canLose    = $PokemonTemp.battleRules["canLose"] || false
  expGain    = $PokemonTemp.battleRules["expGain"] != false
  moneyGain  = $PokemonTemp.battleRules["moneyGain"] != false
  Events.onStartBattle.trigger(nil)
  event = (pbMapInterpreterRunning? ? pbMapInterpreter.get_character(0) : nil) rescue nil
  event = nil unless event.is_a?(Game_Event)
  $PokemonTemp.clearBattleRules
  Audio.me_stop
  $game_temp.in_battle = true
  decision = 0
  begin
    decision = RTB::Battle.new(nil, false, trainer: trainer, trainer_event: event, can_lose: canLose,
                               exp_gain: expGain, money_gain: moneyGain).run
  rescue StandardError => e
    $game_temp.in_battle = false
    RTB.report_failure(e)
    setBattleRule("outcomeVar", outcomeVar) if outcomeVar != 1
    setBattleRule("canLose") if canLose
    setBattleRule("noexp") if !expGain
    setBattleRule("nomoney") if !moneyGain
    return aj_turn_based_pbTrainerBattleCore(trainer)
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
