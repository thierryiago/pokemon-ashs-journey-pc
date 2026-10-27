#==============================================================================
# Batalha em tempo real — física do mapa
#
# Por onde os Pokémon andam e os golpes voam durante a luta. Segue as mesmas
# regras de passagem do jogador (Game_Map#passable? do Essentials): paredes,
# água, barrancos (ledges), cercas que bloqueiam só um lado do tile e eventos
# sólidos (pedras, árvores, NPCs, o treinador e o próprio jogador).
#==============================================================================
module RTB
  module_function

  DIR_BIT = { 2 => 0x01, 4 => 0x02, 6 => 0x04, 8 => 0x08 }

  # Em cima de uma ponte? Fora dela, os tiles de ponte são ignorados (passa por baixo).
  def on_bridge?
    defined?($PokemonGlobal) && $PokemonGlobal && $PokemonGlobal.respond_to?(:bridge) &&
      $PokemonGlobal.bridge.to_i > 0
  end

  # Tile em que um Pokémon pode ficar a pé (chão; sem parede, água ou barranco).
  def tile_walkable?(tx, ty)
    return false unless $game_map.valid?(tx, ty)
    [2, 1, 0].each do |i|
      tid = $game_map.data[tx, ty, i]
      next if !tid || tid == 0
      tag = GameData::TerrainTag.try_get($game_map.terrain_tags[tid])
      if tag && tag.respond_to?(:bridge) && tag.bridge
        next unless on_bridge?
        return $game_map.passages[tid] & 0x0f != 0x0f
      end
      return false if tag && (tag.can_surf || tag.ledge)
      next if tag && tag.ignore_passability
      pas = $game_map.passages[tid]
      return false if pas & 0x0f == 0x0f
      return true if $game_map.priorities[tid] == 0
    end
    true
  end

  # Tile por onde um golpe pode voar: só paredes cheias o param (passa por cima de
  # água, barrancos e cercas baixas).
  def tile_flyable?(tx, ty)
    return false unless $game_map.valid?(tx, ty)
    [2, 1, 0].each do |i|
      tid = $game_map.data[tx, ty, i]
      next if !tid || tid == 0
      tag = GameData::TerrainTag.try_get($game_map.terrain_tags[tid])
      next if tag && tag.respond_to?(:bridge) && tag.bridge && !on_bridge?
      next if tag && (tag.ignore_passability || tag.can_surf || tag.ledge)
      return false if $game_map.passages[tid] & 0x0f == 0x0f
      return true if $game_map.priorities[tid] == 0
    end
    true
  end

  # Dá para sair do tile pelo lado d (2 baixo, 4 esquerda, 6 direita, 8 cima)?
  # Cercas e muros costumam bloquear só alguns lados do tile.
  def tile_side_open?(tx, ty, d)
    return false unless $game_map.valid?(tx, ty)
    bit = DIR_BIT[d]
    [2, 1, 0].each do |i|
      tid = $game_map.data[tx, ty, i]
      next if !tid || tid == 0
      tag = GameData::TerrainTag.try_get($game_map.terrain_tags[tid])
      if tag && tag.respond_to?(:bridge) && tag.bridge
        next unless on_bridge?
        pas = $game_map.passages[tid]
        return pas & bit == 0 && pas & 0x0f != 0x0f
      end
      next if tag && tag.ignore_passability
      pas = $game_map.passages[tid]
      return false if pas & bit != 0 || pas & 0x0f == 0x0f
      return true if $game_map.priorities[tid] == 0
    end
    true
  end

  # Passa do tile (x1, y1) para o vizinho (x2, y2)? Mesma conta do jogador:
  # o lado de saída do primeiro e o de entrada do segundo precisam estar livres.
  def tiles_crossable?(x1, y1, x2, y2)
    d = if x2 > x1 then 6 elsif x2 < x1 then 4 elsif y2 > y1 then 2 else 8 end
    tile_side_open?(x1, y1, d) && tile_side_open?(x2, y2, 10 - d)
  end

  # Tiles ocupados por eventos sólidos (pedras, árvores de corte, placas, NPCs,
  # o treinador) e pelo próprio jogador, que fica parado durante a luta.
  def solid_event_tiles
    tiles = {}
    if $game_map.respond_to?(:events) && $game_map.events
      $game_map.events.each_value do |ev|
        next if ev.through || (ev.respond_to?(:erased) && ev.erased)
        next if ev.character_name.to_s.empty? && ev.tile_id.to_i <= 0
        tiles[[ev.x, ev.y]] = true
      end
    end
    tiles[[$game_player.x, $game_player.y]] = true if $game_player
    tiles
  rescue StandardError
    {}
  end

end
