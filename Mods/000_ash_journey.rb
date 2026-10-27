#==============================================================================
# Pokémon Ash's Journey — configuração geral do mod
#==============================================================================
module AshJourney
  VERSION = "0.1.0-b0"

  # Batalha em tempo real (plano v0.5, seção 7). false = todas as batalhas por turno,
  # sem nem aparecer a opção no menu.
  REALTIME_WILD_BATTLES = true

  # Ajustes de balanceamento da batalha em tempo real (1.0 = fórmula do jogo).
  # Dano maior que 1.0 deixa as lutas mais curtas; recarga maior deixa mais lentas.
  RT_DAMAGE_SCALE   = 0.4
  RT_COOLDOWN_SCALE = 1.0

  # Velocidade da batalha em tempo real (1.0 = normal, 0.5 = metade da velocidade).
  # Vale para tudo dentro da luta: andar, golpes, projéteis, recargas e a IA.
  RT_TIME_SCALE = 0.5

  # Velocidade das animações de golpe (as mesmas das batalhas por turno).
  RT_ANIM_SPEED = 1.0
  # Tamanho dos Pokémon na batalha em tempo real (1.0 = tamanho original do sprite)
  RT_SPRITE_SCALE = 1.5
end

#------------------------------------------------------------------------------
# D5: o jogo não acessa a rede. O Mystery Gift do Fire Ash baixava presentes
# de um Pastebin; aqui toda tentativa de download volta vazia, então o jogo
# mostra "nenhum presente" sem tentar se conectar.
#------------------------------------------------------------------------------
def pbDownloadData(url, filename = nil, authorization = nil, depth = 0, &block)
  return nil
end

def pbDownloadToString(url)
  return ""
end

def pbDownloadToFile(url, file)
  return
end

def pbPostData(url, postdata, filename = nil, depth = 0)
  return ""
end

def pbPostToString(url, postdata)
  return ""
end

def pbPostToFile(url, postdata, file)
  return
end

#------------------------------------------------------------------------------
# Opções "Batalha selvagem" e "Batalha de treinador" no menu (R4): tempo real ou por turno.
# Fica no $PokemonSystem, salvo junto com as outras opções; saves antigos
# começam em "Tempo real".
#------------------------------------------------------------------------------
class PokemonSystem
  attr_writer :aj_battle_mode

  def aj_battle_mode
    @aj_battle_mode || 0   # 0 = tempo real, 1 = por turno
  end

  attr_writer :aj_trainer_mode

  def aj_trainer_mode
    @aj_trainer_mode || 0  # 0 = por turno (padrão no B0), 1 = tempo real
  end
end

class PokemonOption_Scene
  unless method_defined?(:aj_original_pbAddOnOptions)
    alias aj_original_pbAddOnOptions pbAddOnOptions
  end

  def pbAddOnOptions(options)
    options = aj_original_pbAddOnOptions(options)
    options.push(EnumOption.new(_INTL("Batalha selvagem"), [_INTL("Tempo real"), _INTL("Turnos")],
                                proc { $PokemonSystem.aj_battle_mode },
                                proc { |value| $PokemonSystem.aj_battle_mode = value }))
    options.push(EnumOption.new(_INTL("Batalha de treinador"), [_INTL("Turnos"), _INTL("Tempo real")],
                                proc { $PokemonSystem.aj_trainer_mode },
                                proc { |value| $PokemonSystem.aj_trainer_mode = value }))
    options
  end
end
