#==============================================================================
# Batalha em tempo real — cena no próprio mapa (RGSS / mkxp-z)
#
# Controles (plano v0.5, R2): WASD ou setas movem, 1-4 usam os golpes,
# Espaço esquiva, F lança a Poké Bola, Q troca de Pokémon, segurar Esc/X foge.
#==============================================================================
module RTB
  ARENA_W = 13   # tiles
  ARENA_H = 9

  TYPE_COLORS = {
    NORMAL: [168, 168, 120], FIRE: [240, 128, 48], WATER: [104, 144, 240],
    ELECTRIC: [248, 208, 48], GRASS: [120, 200, 80], ICE: [152, 216, 216],
    FIGHTING: [192, 48, 40], POISON: [160, 64, 160], GROUND: [224, 192, 104],
    FLYING: [168, 144, 240], PSYCHIC: [248, 88, 136], BUG: [168, 184, 32],
    ROCK: [184, 160, 56], GHOST: [112, 88, 152], DRAGON: [112, 56, 248],
    DARK: [112, 88, 72], STEEL: [184, 184, 208], FAIRY: [238, 153, 172]
  }

  STATUS_NAMES = {
    SLEEP: "dormiu", POISON: "foi envenenado", BURN: "se queimou",
    PARALYSIS: "ficou paralisado", FROZEN: "congelou", CONFUSED: "ficou confuso"
  }

  STAGE_NAMES = { atk: "Ataque", def: "Defesa", spa: "At. Esp.", spd: "Def. Esp.", spe: "Velocidade" }

  BALLS = { POKEBALL: 1.0, GREATBALL: 1.5, ULTRABALL: 2.0, PREMIERBALL: 1.0 }

  # Gerador de números da batalha. Os testes fixam uma semente aqui.
  class << self
    attr_accessor :rng_override
  end

  module_function

  def key_press?(sym)
    Input.pressex?(sym)
  rescue StandardError
    false
  end

  def key_trigger?(sym)
    Input.triggerex?(sym)
  rescue StandardError
    false
  end

  def type_color(type, alpha = 255)
    c = TYPE_COLORS[type.to_s.to_sym] || [255, 255, 255]
    Color.new(c[0], c[1], c[2], alpha)
  end

  # Spec de tempo real a partir de um golpe do Pokémon (Pokemon::Move).
  def spec_for_move(move)
    data = GameData::Move.get(move.id)
    classify(id: data.id, name: data.name, type: data.type, category: data.category,
             power: data.base_damage, function_code: data.function_code,
             effect_chance: data.effect_chance, target: data.target,
             flags: data.flags, priority: data.priority)
  end

  # Tile em que um Pokémon pode ficar (chão, sem parede, sem água).
  def tile_walkable?(tx, ty)
    return false unless $game_map.valid?(tx, ty)
    [2, 1, 0].each do |i|
      tid = $game_map.data[tx, ty, i]
      next if !tid || tid == 0
      tag = GameData::TerrainTag.try_get($game_map.terrain_tags[tid])
      return false if tag && tag.can_surf
      next if tag && tag.ignore_passability
      pas = $game_map.passages[tid]
      return false if pas & 0x0f == 0x0f
      return true if $game_map.priorities[tid] == 0
    end
    true
  end

  #----------------------------------------------------------------------------
  # Sprites do PMD SpriteCollab (Graphics/RTB/<ESPÉCIE>/, ver tools/fetch_pmd_sprites.py)
  #----------------------------------------------------------------------------
  @pmd = {}

  # { "Walk" => { w:, h:, durs: [quadros a 60 fps], hit:, bitmap: }, ... } ou nil
  def pmd_anims(species)
    key = species.to_s
    return @pmd[key] if @pmd.key?(key)
    data = nil
    path = "Graphics/RTB/#{key}/anim.txt"
    if File.exist?(path)
      data = {}
      File.readlines(path).each do |line|
        name, w, h, durs, hit = line.split
        next unless name && w
        file = pbResolveBitmap("Graphics/RTB/#{key}/#{name}")
        next unless file
        data[name] = { w: w.to_i, h: h.to_i, durs: durs.split(",").map(&:to_i), hit: hit.to_i,
                       bitmap: RPG::Cache.load_bitmap("", file) }
      end
      data = nil unless data["Walk"]
    end
    @pmd[key] = data
  end

  # Linha da folha do PMD para a direção (fx, fy): 0 baixo, 2 direita, 4 cima, 6 esquerda.
  def pmd_row(fx, fy)
    ang = Math.atan2(fy, fx) * 180 / Math::PI
    ((90 - ang) / 45.0).round % 8
  end

  #----------------------------------------------------------------------------
  # Sprite de um Pokémon em campo: PMD (8 direções, ataque) quando houver;
  # senão o sprite de seguidor do Fire Ash (4 direções).
  #----------------------------------------------------------------------------
  class FighterSprite
    attr_reader :fighter

    def initialize(fighter, viewport)
      @fighter = fighter
      @sprite = Sprite.new(viewport)
      @shadow = Sprite.new(viewport)
      @shadow.bitmap = RTB.circle_bitmap(9, Color.new(0, 0, 0, 90))
      @shadow.ox = 9; @shadow.oy = 9; @shadow.zoom_y = 0.5
      @pmd = RTB.pmd_anims(fighter.pkmn.species)
      unless @pmd
        @sprite.bitmap = RTB.pokemon_bitmap(fighter.pkmn)
        @fw = @sprite.bitmap.width / 4
        @fh = @sprite.bitmap.height / 4
        @sprite.ox = @fw / 2
        @sprite.oy = @fh - 6
      end
      @last = [fighter.x, fighter.y]
      @frame_t = 0.0
      @frame = 0
      @appear = 0.0
      @anim = nil
      @action = nil      # animação de golpe em andamento ("Attack"/"Shoot")
      @action_t = 0.0
    end

    def update(dt)
      f = @fighter
      moving = (f.x - @last[0]).abs > 0.1 || (f.y - @last[1]).abs > 0.1
      @last = [f.x, f.y]
      @pmd ? update_pmd(f, moving, dt) : update_follower(f, moving, dt)
      sx, sy = RTB.screen_xy(f.x, f.y)
      @sprite.x = sx; @sprite.y = sy
      @shadow.x = sx; @shadow.y = sy + (@pmd ? 4 : 0)
      @sprite.z = sy.to_i + 2
      @shadow.z = sy.to_i
      @appear += dt
      @sprite.visible = !f.hidden
      @shadow.visible = !f.hidden && !f.fainted?
      @sprite.opacity = f.fainted? ? [@sprite.opacity - 12, 0].max : [(@appear / 0.3 * 255).to_i, 255].min
      @sprite.opacity = 140 if f.invuln > 0 && f.dodge
      @sprite.color =
        if f.flash > 0 then Color.new(255, 255, 255, 200)
        elsif f.status == :PARALYSIS then Color.new(248, 208, 48, 60)
        elsif f.status == :BURN then Color.new(240, 96, 48, 60)
        elsif f.status == :POISON then Color.new(160, 64, 160, 70)
        elsif f.status == :FROZEN then Color.new(152, 216, 248, 140)
        elsif f.status == :SLEEP then Color.new(40, 40, 80, 80)
        else Color.new(0, 0, 0, 0)
        end
      @sprite.tone = (f.lock > 0 && f.pending) ? Tone.new(40, 40, 40) : Tone.new(0, 0, 0)
    end

    def update_follower(f, moving, dt)
      @frame_t += dt
      if moving && @frame_t > 0.12
        @frame = (@frame + 1) % 4; @frame_t = 0
      elsif !moving
        @frame = 0
      end
      row = if f.fy.abs >= f.fx.abs
              f.fy > 0 ? 0 : 3
            else
              f.fx < 0 ? 1 : 2
            end
      @sprite.src_rect.set(@frame * @fw, row * @fh, @fw, @fh)
    end

    def update_pmd(f, moving, dt)
      # Começa a animação de golpe quando ele é preparado
      if f.pending && !@action
        kind = f.pending[0].kind
        @action = [:melee, :dash].include?(kind) ? "Attack" : "Shoot"
        @action = "Attack" unless @pmd[@action]
        @action_t = 0.0
      end
      name =
        if f.fainted? || f.flash > 0 then "Hurt"
        elsif @action then @action
        elsif moving || f.dash || f.dodge then "Walk"
        else "Idle"
        end
      name = "Walk" unless @pmd[name]
      a = @pmd[name]
      if name != @anim
        @anim = name; @frame = 0; @frame_t = 0.0
      end
      total = a[:durs].sum / 60.0
      @frame_t += dt
      if @action && name == @action
        @action_t += dt
        @action = nil if @action_t >= total && !f.pending
      end
      t = name == "Hurt" && f.fainted? ? total - 0.001 : @frame_t % total
      acc = 0.0
      @frame = a[:durs].length - 1
      a[:durs].each_with_index do |d, i|
        acc += d / 60.0
        if t < acc
          @frame = i
          break
        end
      end
      @frame = 0 if name == "Walk" && !moving && !f.dash && !f.dodge
      @sprite.bitmap = a[:bitmap]
      row = RTB.pmd_row(f.fx, f.fy)
      row = 0 if a[:bitmap].height < (row + 1) * a[:h]   # folhas de uma direção só
      @sprite.src_rect.set(@frame * a[:w], row * a[:h], a[:w], a[:h])
      @sprite.ox = a[:w] / 2
      @sprite.oy = a[:h] / 2 + 6
    end

    def dispose
      @sprite.dispose
      @shadow.dispose
    end
  end

  @circles = {}

  def circle_bitmap(r, color, ring = false)
    key = [r, color.red, color.green, color.blue, color.alpha, ring]
    bmp = @circles[key]
    return bmp if bmp && !bmp.disposed?
    d = r * 2 + 1
    bmp = Bitmap.new(d, d)
    (0...d).each do |yy|
      dy = yy - r
      half = Math.sqrt([r * r - dy * dy, 0].max).floor
      if ring
        inner = Math.sqrt([(r - 3) * (r - 3) - dy * dy, 0].max).floor
        bmp.fill_rect(r - half, yy, half - inner, 1, color)
        bmp.fill_rect(r + inner, yy, half - inner + 1, 1, color)
      else
        bmp.fill_rect(r - half, yy, half * 2 + 1, 1, color)
      end
    end
    @circles[key] = bmp
  end

  def pokemon_bitmap(pkmn)
    names = []
    sp = pkmn.species.to_s
    names.push("#{sp}_#{pkmn.form}") if pkmn.form && pkmn.form > 0
    names.push(sp)
    names.each do |n|
      path = pbResolveBitmap("Graphics/Characters/#{n}")
      return RPG::Cache.load_bitmap("", path) if path
    end
    # Reserva: um círculo da cor do tipo (4x4 quadros iguais)
    bmp = Bitmap.new(96, 96)
    c = type_color(pkmn.types[0])
    4.times { |i| 4.times { |j| bmp.blt(i * 24 + 4, j * 24 + 4, circle_bitmap(8, c), Rect.new(0, 0, 17, 17)) } }
    bmp
  end

  def screen_xy(px, py)
    [px - $game_map.display_x.to_f / Game_Map::X_SUBPIXELS,
     py - $game_map.display_y.to_f / Game_Map::Y_SUBPIXELS]
  end

  #----------------------------------------------------------------------------
  # A batalha
  #----------------------------------------------------------------------------
  class Battle
    attr_reader :decision

    # foe: Pokémon selvagem (ou o primeiro do treinador).
    # trainer: NPCTrainer numa batalha de treinador; trainer_event: o evento dele no mapa.
    def initialize(foe, can_run = true, trainer: nil, trainer_event: nil, can_lose: false)
      @trainer = trainer
      @trainer_event = trainer_event
      @foe_party = trainer ? trainer.party : [foe]
      @foe_pkmn = trainer ? @foe_party.find { |p| p.able? } : foe
      @can_run = can_run && !trainer
      @can_lose = can_lose
      @decision = 0
      @participants = []
      @defeated = []   # [Pokémon derrotado, índices de quem lutou contra ele]
      @caught = nil
      @texts = []
      @run_hold = 0.0
      @hud_tick = 0
      @end_t = nil
    end

    def run
      setup
      intro
      loop do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        dt = 1.0 / Graphics.frame_rate
        unless @end_t
          handle_input(dt)
          @sim.update(dt, { 0 => @input })
          process_events
        end
        update_visuals(dt)
        check_end(dt)
        break if @end_t && @end_t <= 0
      end
      teardown
      after_battle
      @decision
    end

    #--------------------------------------------------------------------------
    def setup
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 150
      @hud_vp = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @hud_vp.z = 160
      # Arena: retângulo de tiles em volta do jogador, dentro do mapa
      ptx = $game_player.x; pty = $game_player.y
      ax = [[ptx - ARENA_W / 2, 0].max, [$game_map.width - ARENA_W, 0].max].min
      ay = [[pty - ARENA_H / 2, 0].max, [$game_map.height - ARENA_H, 0].max].min
      aw = [ARENA_W, $game_map.width].min; ah = [ARENA_H, $game_map.height].min
      @arena_tiles = [ax, ay, aw, ah]
      arena = [ax * 32, ay * 32, (ax + aw) * 32 - 1, (ay + ah) * 32 - 1]
      walk_cache = {}
      walkable = lambda do |px, py|
        tx = (px / 32).floor; ty = (py / 32).floor
        k = tx * 10_000 + ty
        walk_cache.key?(k) ? walk_cache[k] : (walk_cache[k] = RTB.tile_walkable?(tx, ty))
      end
      type_mult = lambda do |mtype, dtypes|
        Effectiveness.calculate(mtype, *dtypes[0, 3]).to_f / Effectiveness::NORMAL_EFFECTIVE
      end
      @sim = Sim.new(arena: arena, walkable: walkable, type_mult: type_mult, ai_level: @trainer ? 1 : 0,
                     rng: RTB.rng_override || Random.new)
      # Posições iniciais: o Pokémon do jogador ao lado do treinador, o selvagem à frente
      px = $game_player.x * 32 + 16; py = $game_player.y * 32 + 16
      dx, dy = dir_vector($game_player.direction)
      @player_tile = [$game_player.x, $game_player.y]
      @lead_index = $Trainer.party.index { |p| p.able? }
      me = spawn_point(px + dx * 36 - dy * 28, py + dy * 36 + dx * 28, arena, walkable)
      @mine = add_player_fighter(@lead_index, me[0], me[1])
      @mine.fx, @mine.fy = dx, dy
      if @trainer_event
        # O Pokémon do treinador sai na frente dele, virado para o jogador
        ex = @trainer_event.x * 32 + 16; ey = @trainer_event.y * 32 + 16
        ux, uy = norm_dir(px - ex, py - ey)
        foe_at = spawn_point(ex + ux * 40, ey + uy * 40, arena, walkable)
      else
        foe_at = spawn_point(px + dx * 130, py + dy * 130, arena, walkable)
      end
      @foe_at = foe_at
      @enemy = add_foe_fighter(@foe_pkmn, foe_at[0], foe_at[1])
      @enemy.fx, @enemy.fy = norm_dir(me[0] - foe_at[0], me[1] - foe_at[1])
      @sprites = [FighterSprite.new(@mine, @viewport), FighterSprite.new(@enemy, @viewport)]
      @fx_sprites = []
      @text_sprites = []
      @border = Sprite.new(@viewport)
      @border.bitmap = Bitmap.new(aw * 32, ah * 32)
      c = Color.new(255, 255, 255, 110)
      @border.bitmap.fill_rect(0, 0, aw * 32, 2, c)
      @border.bitmap.fill_rect(0, ah * 32 - 2, aw * 32, 2, c)
      @border.bitmap.fill_rect(0, 0, 2, ah * 32, c)
      @border.bitmap.fill_rect(aw * 32 - 2, 0, 2, ah * 32, c)
      @border.z = 1
      build_hud
      hide_followers
      @input = { mx: 0, my: 0 }
      $Trainer.pokedex.register(@foe_pkmn)
      @bgm_before = $game_system.getPlayingBGM
      $game_system.bgm_pause
      pbBGMPlay(@trainer ? pbGetTrainerBattleBGM([@trainer]) : pbGetWildBattleBGM([@foe_pkmn]))
    end

    def norm_dir(x, y)
      l = Math.sqrt(x * x + y * y)
      l > 0 ? [x / l, y / l] : [0.0, 1.0]
    end

    def add_foe_fighter(pkmn, x, y)
      @sim.add(Fighter.new(pkmn, 1, pkmn.moves.map { |m| RTB.spec_for_move(m) }, x, y))
    end

    # Esconde quem segue o jogador (ex.: o Pikachu do Fire Ash) durante a luta,
    # para não aparecer um Pokémon repetido ao lado do que está lutando.
    def hide_followers
      @followers_visible = $PokemonGlobal.followers.map { |f| [f, f.visible] }
      @followers_visible.each { |f, _| f.visible = false }
    rescue StandardError
      @followers_visible = []
    end

    def restore_followers
      (@followers_visible || []).each { |f, v| f.visible = v }
    end

    def dir_vector(d)
      case d
      when 2 then [0, 1]
      when 4 then [-1, 0]
      when 6 then [1, 0]
      else [0, -1]
      end
    end

    # Ponto livre mais perto de (x, y) dentro da arena.
    def spawn_point(x, y, arena, walkable)
      x = x.clamp(arena[0] + 16, arena[2] - 16); y = y.clamp(arena[1] + 16, arena[3] - 16)
      return [x, y] if walkable.call(x, y)
      (1..8).each do |r|
        [[1, 0], [-1, 0], [0, 1], [0, -1], [1, 1], [-1, -1], [1, -1], [-1, 1]].each do |ox, oy|
          nx = (x + ox * r * 32).clamp(arena[0] + 16, arena[2] - 16)
          ny = (y + oy * r * 32).clamp(arena[1] + 16, arena[3] - 16)
          return [nx, ny] if walkable.call(nx, ny)
        end
      end
      [$game_player.x * 32 + 16, $game_player.y * 32 + 16]
    end

    def add_player_fighter(index, x, y)
      pkmn = $Trainer.party[index]
      @participants.push(index) unless @participants.include?(index)
      @sim.add(Fighter.new(pkmn, 0, pkmn.moves.map { |m| RTB.spec_for_move(m) }, x, y))
    end

    def intro
      $game_screen.start_flash(Color.new(255, 255, 255, 180), 8) rescue nil
      if @trainer
        float_text(@enemy, _INTL("{1} quer lutar!", @trainer.full_name), Color.new(255, 255, 255), 1.4)
        float_text(@enemy, _INTL("{1} mandou {2}!", @trainer.name, @foe_pkmn.name), Color.new(255, 220, 220), 1.4)
      else
        float_text(@enemy, _INTL("Um {1} selvagem apareceu!", @foe_pkmn.name), Color.new(255, 255, 255), 1.4)
      end
      float_text(@mine, _INTL("Vai, {1}!", @mine.name), Color.new(255, 255, 160), 1.0)
      @sim.frozen = true
      (Graphics.frame_rate * 0.6).to_i.times do
        Graphics.update; Input.update; pbUpdateSceneMap
        update_visuals(1.0 / Graphics.frame_rate)
      end
      @sim.frozen = false
    end

    #--------------------------------------------------------------------------
    # Entrada do jogador
    #--------------------------------------------------------------------------
    def handle_input(dt)
      mx = 0; my = 0
      mx -= 1 if RTB.key_press?(:A) || Input.press?(Input::LEFT)
      mx += 1 if RTB.key_press?(:D) || Input.press?(Input::RIGHT)
      my -= 1 if RTB.key_press?(:W) || Input.press?(Input::UP)
      my += 1 if RTB.key_press?(:S) || Input.press?(Input::DOWN)
      use = nil
      [:NUMBER_1, :NUMBER_2, :NUMBER_3, :NUMBER_4].each_with_index do |k, i|
        use = i if RTB.key_trigger?(k) || RTB.key_trigger?(:"KP_#{i + 1}")
      end
      @input = { mx: mx, my: my, use: use, dodge: RTB.key_trigger?(:SPACE) }
      if use && @mine.specs[use] && @mine.cds[use] <= 0 && !@mine.busy? &&
         @mine.move_pp(use) <= 0 && !@mine.all_out_of_pp?
        float_text(@mine, _INTL("Sem PP!"), Color.new(255, 160, 160), 0.6)
      end
      throw_ball if RTB.key_trigger?(:F)
      switch_pokemon if RTB.key_trigger?(:Q)
      if Input.press?(Input::BACK)
        @run_hold += dt
        if @run_hold >= 0.8
          @run_hold = 0
          try_run
        end
      else
        @run_hold = 0
      end
    end

    def try_run
      if !@can_run
        msg = @trainer ? _INTL("Não dá para fugir de um treinador!") : _INTL("Não dá para fugir!")
        float_text(@mine, msg, Color.new(255, 160, 160), 0.9)
        return
      end
      pbSEPlay("Battle flee")
      float_text(@mine, _INTL("Fugiu em segurança!"), Color.new(255, 255, 255), 0.8)
      finish(3, 0.6)
    end

    def switch_pokemon
      return if @mine.busy? && !@mine.fainted?
      party = $Trainer.party
      cur = party.index(@mine.pkmn)
      nxt = (1...party.length).map { |o| (cur + o) % party.length }.find { |i| party[i].able? }
      unless nxt
        float_text(@mine, _INTL("Nenhum outro Pokémon pode lutar."), Color.new(255, 200, 200), 0.8)
        return
      end
      send_out(nxt, _INTL("Volta, {1}! Vai, {2}!", @mine.name, party[nxt].name))
    end

    def send_out(index, text)
      old = @mine
      old.hidden = true
      new_f = add_player_fighter(index, old.x, old.y)
      new_f.fx, new_f.fy = old.fx, old.fy
      new_f.lock = 0.4
      new_f.invuln = 0.6
      @sim.remove(old)
      @sprites.find { |s| s.fighter == old }&.dispose
      @sprites.reject! { |s| s.fighter == old }
      @sprites.push(FighterSprite.new(new_f, @viewport))
      @mine = new_f
      float_text(new_f, text, Color.new(255, 255, 160), 1.0)
      @hud_tick = 0
    end

    #--------------------------------------------------------------------------
    # Poké Bola: sempre acerta (R5); a chance segue a fórmula clássica
    #--------------------------------------------------------------------------
    def throw_ball
      return if @enemy.fainted? || @sim.frozen
      if @trainer
        float_text(@enemy, _INTL("Não dá para capturar o Pokémon de um treinador!"), Color.new(255, 160, 160), 1.0)
        return
      end
      ball = BALLS.keys.find { |b| GameData::Item.exists?(b) && $PokemonBag.pbHasItem?(b) }
      unless ball
        float_text(@mine, _INTL("Você não tem Poké Bolas!"), Color.new(255, 160, 160), 0.9)
        return
      end
      $PokemonBag.pbDeleteItem(ball)
      @sim.frozen = true
      shakes = capture_shakes(ball)
      ball_sprite = Sprite.new(@viewport)
      ball_sprite.bitmap = RTB.circle_bitmap(5, Color.new(230, 40, 40))
      ball_sprite.ox = 5; ball_sprite.oy = 5; ball_sprite.z = 9999
      sx = $game_player.x * 32 + 16; sy = $game_player.y * 32
      frames = (Graphics.frame_rate * 0.45).to_i
      frames.times do |i|
        t = (i + 1).to_f / frames
        x = sx + (@enemy.x - sx) * t
        y = sy + (@enemy.y - sy) * t - Math.sin(t * Math::PI) * 40
        ball_sprite.x, ball_sprite.y = RTB.screen_xy(x, y)
        Graphics.update; Input.update; pbUpdateSceneMap
        update_visuals(1.0 / Graphics.frame_rate)
      end
      @enemy.hidden = true
      update_visuals(0)
      pbSEPlay("Battle recall")
      [shakes, 3].min.times do
        (Graphics.frame_rate / 2).times do |i|
          ball_sprite.angle = Math.sin(i * 0.6) * 25
          Graphics.update; Input.update; pbUpdateSceneMap
        end
        pbSEPlay("Battle ball shake")
      end
      ball_sprite.dispose
      if shakes >= 4
        pbSEPlay("Battle catch click")
        @caught = ball
        float_text(@enemy, _INTL("Gotcha! {1} foi capturado!", @foe_pkmn.name), Color.new(255, 255, 160), 1.6)
        finish(4, 1.4)
      else
        @enemy.hidden = false
        float_text(@enemy, [_INTL("Escapou!"), _INTL("Quase!"), _INTL("Por pouco!")][[shakes, 2].min],
                   Color.new(255, 200, 200), 0.9)
        @sim.frozen = false
      end
    end

    def capture_shakes(ball)
      return 4 if ball == :MASTERBALL
      pkmn = @foe_pkmn
      rate = pkmn.species_data.catch_rate * BALLS[ball]
      a = pkmn.totalhp; b = pkmn.hp
      x = ((3 * a - 2 * b) * rate.to_f) / (3 * a)
      if [:SLEEP, :FROZEN].include?(pkmn.status) then x *= 2.5
      elsif pkmn.status != :NONE then x *= 1.5
      end
      x = x.floor
      x = 1 if x < 1
      return 4 if x >= 255
      y = (65_536 / ((255.0 / x)**0.1875)).floor
      n = 0
      4.times do
        break if rand(65_536) >= y
        n += 1
      end
      n
    end

    #--------------------------------------------------------------------------
    # Eventos da simulação -> textos e efeitos
    #--------------------------------------------------------------------------
    def process_events
      @sim.events.each do |ev|
        type, f = ev[0], ev[1]
        case type
        when :damage
          dmg, mult, crit = ev[2], ev[3], ev[4]
          col = mult > 1 ? Color.new(255, 220, 80) : (mult < 1 ? Color.new(180, 180, 180) : Color.new(255, 255, 255))
          float_text(f, crit ? "#{dmg}!" : dmg.to_s, col, 0.6)
          float_text(f, _INTL("É super efetivo!"), col, 0.9) if mult > 1 && f.side == 1 && dmg > 0
          @hud_tick = 0
        when :heal
          float_text(f, "+#{ev[2]}", Color.new(120, 255, 120), 0.7); @hud_tick = 0
        when :faint
          float_text(f, _INTL("{1} desmaiou!", f.name), Color.new(255, 140, 140), 1.2)
          pbSEPlay("Battle damage weak") rescue nil
          @hud_tick = 0
        when :status
          float_text(f, "#{f.name} #{STATUS_NAMES[ev[2]] || ev[2]}!", Color.new(255, 200, 120), 1.0)
          @hud_tick = 0
        when :stages
          ev[2].each do |k, v|
            word = v > 0 ? (v > 1 ? "subiu muito" : "subiu") : (v < -1 ? "caiu muito" : "caiu")
            float_text(f, "#{STAGE_NAMES[k]} #{word}", Color.new(200, 220, 255), 0.9)
          end
        when :text
          float_text(f, ev[2], Color.new(255, 255, 255), 0.8) unless ev[2].to_s.empty?
        when :use
          @hud_tick = 0
        end
      end
      @sim.events.clear
    end

    def float_text(f, text, color, dur)
      s = Sprite.new(@hud_vp)
      w = [text.length * 8 + 16, 32].max
      s.bitmap = Bitmap.new(w, 22)
      pbSetSmallFont(s.bitmap)
      s.bitmap.font.color = Color.new(0, 0, 0, 200)
      s.bitmap.draw_text(1, 1, w, 22, text, 1)
      s.bitmap.font.color = color
      s.bitmap.draw_text(0, 0, w, 22, text, 1)
      s.ox = w / 2
      stack = @text_sprites.count { |t| t[1] == f && t[2] < 0.3 }
      @text_sprites.push([s, f, 0.0, dur, stack])
    end

    #--------------------------------------------------------------------------
    # Desenho
    #--------------------------------------------------------------------------
    def update_visuals(dt)
      @sprites.each { |s| s.update(dt) }
      bx, by = RTB.screen_xy(@arena_tiles[0] * 32, @arena_tiles[1] * 32)
      @border.x = bx; @border.y = by
      draw_effects
      @text_sprites.each do |t|
        s, f, age, dur, stack = t
        t[2] = age + dt
        sx, sy = RTB.screen_xy(f.x, f.y)
        s.x = sx; s.y = sy - 44 - stack * 16 - t[2] * 18
        s.opacity = t[2] > dur - 0.25 ? [((dur - t[2]) / 0.25 * 255).to_i, 0].max : 255
      end
      @text_sprites.reject! { |t| (t[2] >= t[3]) && (t[0].bitmap.dispose; t[0].dispose; true) }
      @hud_tick -= 1
      if @hud_tick <= 0
        draw_hud
        @hud_tick = 4
      end
    end

    # Sprites de efeito reaproveitados de um quadro para o outro (criar e
    # descartar sprites a cada quadro pesa no mkxp-z).
    def fx_sprite(i)
      s = @fx_sprites[i]
      unless s
        s = Sprite.new(@viewport)
        @fx_sprites[i] = s
      end
      s.visible = true
      s.zoom_x = 1.0; s.zoom_y = 1.0; s.angle = 0; s.opacity = 255
      s
    end

    def draw_effects
      n = 0
      @sim.projectiles.each do |p|
        s = fx_sprite(n); n += 1
        r = [p.r.to_i, 3].max
        s.bitmap = RTB.circle_bitmap(r, RTB.type_color(p.spec.type))
        s.ox = r; s.oy = r
        s.x, s.y = RTB.screen_xy(p.x, p.y)
        s.z = 9000
      end
      @sim.effects.each do |e|
        prog = e.t / e.max
        s = fx_sprite(n); n += 1
        s.z = 9001
        case e.kind
        when :beam
          s.bitmap = RTB.circle_bitmap(e.r.to_i, RTB.type_color(e.type, 230))
          len = Math.hypot(e.x2 - e.x, e.y2 - e.y)
          s.ox = 0; s.oy = e.r.to_i
          s.zoom_x = len / (e.r * 2 + 1)
          s.angle = -Math.atan2(e.y2 - e.y, e.x2 - e.x) * 180 / Math::PI
          s.opacity = (255 * (1 - prog)).to_i
          s.x, s.y = RTB.screen_xy(e.x, e.y)
        when :ring, :aura
          r = [e.r.to_i, 4].max
          s.bitmap = RTB.circle_bitmap(r, RTB.type_color(e.type, 220), true)
          s.ox = r; s.oy = r
          z = 0.3 + 0.7 * prog
          s.zoom_x = z; s.zoom_y = z
          s.opacity = (255 * (1 - prog)).to_i
          s.x, s.y = RTB.screen_xy(e.x, e.y)
        else # :slash, :puff
          r = [e.r.to_i, 4].max
          s.bitmap = RTB.circle_bitmap(r, RTB.type_color(e.type, 170))
          s.ox = r; s.oy = r
          s.zoom_x = 0.6 + 0.6 * prog; s.zoom_y = s.zoom_x
          s.opacity = (200 * (1 - prog)).to_i
          s.x, s.y = RTB.screen_xy(e.x, e.y)
        end
      end
      (n...@fx_sprites.length).each { |i| @fx_sprites[i].visible = false }
    end

    def build_hud
      @hud = Sprite.new(@hud_vp)
      @hud.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      pbSetSmallFont(@hud.bitmap)
    end

    def draw_bar(b, x, y, w, h, frac)
      b.fill_rect(x - 1, y - 1, w + 2, h + 2, Color.new(20, 20, 20, 220))
      col = frac > 0.5 ? Color.new(80, 208, 96) : (frac > 0.2 ? Color.new(240, 200, 40) : Color.new(232, 72, 56))
      b.fill_rect(x, y, (w * frac).round, h, col) if frac > 0
    end

    def draw_text_shadow(b, x, y, w, h, text, align = 0, color = Color.new(255, 255, 255))
      b.font.color = Color.new(0, 0, 0, 200)
      b.draw_text(x + 1, y + 1, w, h, text, align)
      b.font.color = color
      b.draw_text(x, y, w, h, text, align)
    end

    def status_tag(f)
      { SLEEP: "DOR", POISON: "ENV", BURN: "QUE", PARALYSIS: "PAR", FROZEN: "CON" }[f.status]
    end

    def draw_hud
      b = @hud.bitmap
      b.clear
      gw = Graphics.width; gh = Graphics.height
      # Inimigo (topo)
      e = @enemy
      b.fill_rect(gw / 2 - 110, 6, 220, 32, Color.new(0, 0, 0, 120))
      draw_text_shadow(b, gw / 2 - 104, 6, 150, 18, "#{e.name}  Nv. #{e.level}")
      tag = status_tag(e)
      draw_text_shadow(b, gw / 2 + 50, 6, 52, 18, tag, 2, Color.new(255, 200, 120)) if tag
      draw_bar(b, gw / 2 - 104, 26, 208, 6, e.totalhp > 0 ? e.hp.to_f / e.totalhp : 0)
      # Jogador (baixo, à esquerda)
      m = @mine
      b.fill_rect(4, gh - 66, 170, 62, Color.new(0, 0, 0, 120))
      draw_text_shadow(b, 10, gh - 64, 160, 18, "#{m.name}  Nv. #{m.level}")
      draw_bar(b, 10, gh - 44, 158, 6, m.totalhp > 0 ? m.hp.to_f / m.totalhp : 0)
      draw_text_shadow(b, 10, gh - 38, 158, 18, "#{m.hp}/#{m.totalhp}", 2)
      tag = status_tag(m)
      draw_text_shadow(b, 10, gh - 38, 60, 18, tag, 0, Color.new(255, 200, 120)) if tag
      ready = m.dodge_cd <= 0
      draw_text_shadow(b, 10, gh - 22, 160, 18, _INTL("Espaço: esquiva"), 0,
                       ready ? Color.new(255, 255, 255) : Color.new(140, 140, 140))
      # Golpes (baixo, à direita): 2x2
      m.specs.each_with_index do |spec, i|
        x = gw - 254 + (i % 2) * 126
        y = gh - 62 + (i / 2) * 30
        b.fill_rect(x, y, 122, 26, Color.new(0, 0, 0, 150))
        b.fill_rect(x, y, 4, 26, RTB.type_color(spec.type))
        cd = m.cds[i]
        if cd > 0
          frac = [cd / (spec.cooldown * RTB.cooldown_scale), 1.0].min
          b.fill_rect(x + 4, y, (118 * frac).round, 26, Color.new(0, 0, 0, 120))
        end
        pp = m.move_pp(i)
        mv = m.pkmn.moves[i]
        col = pp <= 0 ? Color.new(255, 120, 120) : (cd > 0 ? Color.new(160, 160, 160) : Color.new(255, 255, 255))
        draw_text_shadow(b, x + 8, y - 2, 110, 18, "#{i + 1} #{spec.name}", 0, col)
        draw_text_shadow(b, x + 8, y + 10, 110, 18, "PP #{pp}/#{mv ? mv.total_pp : 0}", 2,
                         Color.new(200, 200, 200))
      end
      draw_text_shadow(b, gw - 254, gh - 82, 250, 18, _INTL("F: Poké Bola   Q: trocar   Esc: fugir"), 2,
                       Color.new(220, 220, 220))
    end

    #--------------------------------------------------------------------------
    # Fim da batalha
    #--------------------------------------------------------------------------
    def check_end(dt)
      if @end_t
        @end_t -= dt
        return
      end
      if @enemy.fainted?
        unless @defeated.any? { |d| d[0].equal?(@enemy.pkmn) }
          @defeated.push([@enemy.pkmn, @participants.select { |i| $Trainer.party[i] }])
        end
        nxt = @foe_party.find { |p| p.able? }
        if nxt
          @foe_next_t ||= 1.0
          @foe_next_t -= dt
          return if @foe_next_t > 0
          @foe_next_t = nil
          foe_send_out(nxt)
        else
          pbMEPlay(@trainer ? pbGetTrainerVictoryME([@trainer]) : pbGetWildVictoryME)
          finish(1, 1.2)
        end
      elsif @mine.fainted?
        @next_t ||= 1.0
        @next_t -= dt
        return if @next_t > 0
        @next_t = nil
        nxt = $Trainer.party.index { |p| p.able? }
        if nxt
          send_out(nxt, _INTL("Vai, {1}!", $Trainer.party[nxt].name))
        else
          finish(2, 1.0)
        end
      end
    end

    # O treinador manda o próximo Pokémon dele.
    def foe_send_out(pkmn)
      old = @enemy
      @sim.remove(old)
      @sprites.find { |s| s.fighter == old }&.dispose
      @sprites.reject! { |s| s.fighter == old }
      @foe_pkmn = pkmn
      $Trainer.pokedex.register(pkmn)
      @enemy = add_foe_fighter(pkmn, @foe_at[0], @foe_at[1])
      @enemy.fx, @enemy.fy = norm_dir(@mine.x - @foe_at[0], @mine.y - @foe_at[1])
      @enemy.lock = 0.5
      @sprites.push(FighterSprite.new(@enemy, @viewport))
      @participants = [$Trainer.party.index(@mine.pkmn)].compact
      float_text(@enemy, _INTL("{1} mandou {2}!", @trainer.name, pkmn.name), Color.new(255, 220, 220), 1.2)
      @hud_tick = 0
    end

    def finish(decision, delay)
      @decision = decision
      @end_t = delay
      @sim.frozen = true
    end

    def teardown
      @sprites.each(&:dispose)
      @fx_sprites.each(&:dispose)
      @text_sprites.each { |t| t[0].bitmap.dispose; t[0].dispose }
      @border.bitmap.dispose; @border.dispose
      @hud.bitmap.dispose; @hud.dispose
      @viewport.dispose; @hud_vp.dispose
      restore_followers
      $game_system.bgm_resume(@bgm_before) if @decision != 2
    end

    def after_battle
      case @decision
      when 1
        @defeated.each { |foe, gainers| give_exp(foe, gainers) }
        if @trainer
          pbMessage(_INTL("Você derrotou {1}!", @trainer.full_name))
          speech = @trainer.lose_text
          pbMessage(_INTL("{1}: {2}", @trainer.full_name, speech)) if speech && !speech.to_s.empty?
          gain_money
        end
      when 4
        give_exp(@foe_pkmn, @participants) if Settings::GAIN_EXP_FOR_CAPTURE
        store_caught
      when 2
        pbMessage(_INTL("{1} não tem mais Pokémon em condições de lutar!", $Trainer.name))
        lose_money unless @can_lose
      end
    end

    # Mesma conta do pbGainMoney do Essentials.
    def gain_money
      max_level = @trainer.party.map(&:level).max || 0
      money = max_level * @trainer.base_money
      return if money <= 0
      old = $Trainer.money
      $Trainer.money += money
      gained = $Trainer.money - old
      pbMessage(_INTL("Você ganhou ${1} pela vitória!", gained.to_s_formatted)) if gained > 0
    end

    # Mesma conta do pbLoseMoney do Essentials.
    def lose_money
      return if defined?(Settings::NO_MONEY_LOSS) && $game_switches[Settings::NO_MONEY_LOSS]
      max_level = $Trainer.party.map(&:level).max || 0
      mult = [8, 16, 24, 36, 48, 64, 80, 100, 120]
      money = max_level * mult[[$Trainer.badge_count, mult.length - 1].min]
      money = $Trainer.money if money > $Trainer.money
      old = $Trainer.money
      $Trainer.money -= money
      lost = old - $Trainer.money
      return if lost <= 0
      if @trainer
        pbMessage(_INTL("Você deu ${1} para o vencedor...", lost.to_s_formatted))
      else
        pbMessage(_INTL("Na correria, você deixou cair ${1}...", lost.to_s_formatted))
      end
    end

    def store_caught
      pkmn = @foe_pkmn
      pkmn.poke_ball = @caught
      pkmn.makeUnmega if pkmn.mega?
      pkmn.makeUnprimal
      pkmn.heal_status if pkmn.respond_to?(:heal_status)
      pkmn.record_first_moves
      $Trainer.pokedex.register(pkmn)
      unless $Trainer.owned?(pkmn.species)
        $Trainer.pokedex.set_owned(pkmn.species)
        pbMessage(_INTL("Os dados de {1} foram registrados na Pokédex.", pkmn.name)) if $Trainer.has_pokedex
      end
      pbNickname(pkmn)
      pbStorePokemon(pkmn)
    end

    # EXP no modelo do Essentials (pbGainExpOne), só para quem lutou contra foe.
    def give_exp(foe, participants)
      gainers = participants.select { |i| $Trainer.party[i] && $Trainer.party[i].able? }
      return if gainers.empty?
      gainers.each do |i|
        pkmn = $Trainer.party[i]
        growth = pkmn.growth_rate
        next if pkmn.exp >= growth.maximum_exp
        exp = foe.level * foe.base_exp
        exp /= gainers.length if Settings::SPLIT_EXP_BETWEEN_GAINERS
        if Settings::SCALED_EXP_FORMULA
          exp /= 5
          adjust = Math.sqrt(((2 * foe.level + 10.0) / (pkmn.level + foe.level + 10.0))**5)
          exp = (exp * adjust).floor + 1
        else
          exp /= 7
        end
        exp = (exp * 1.5).floor if @trainer
        exp = (exp * 1.5).floor if pkmn.owner.id != $Trainer.id
        exp = (exp * 1.5).floor if GameData::Item.exists?(:EXPCHARM) && $PokemonBag.pbHasItem?(:EXPCHARM)
        gain_evs(pkmn, foe)
        final = growth.add_exp(pkmn.exp, exp)
        gained = final - pkmn.exp
        next if gained <= 0
        pbMessage(_INTL("{1} ganhou {2} pontos de EXP!", pkmn.name, gained))
        old_level = pkmn.level
        pkmn.exp = final
        pkmn.calc_stats
        ((old_level + 1)..pkmn.level).each do |lv|
          pkmn.changeHappiness("levelup")
          pbMessage(_INTL("{1} subiu para o nível {2}!", pkmn.name, lv))
          pkmn.getMoveList.each do |m|
            next if m[0] != lv || pkmn.hasMove?(m[1])
            pbLearnMove(pkmn, m[1], true)
          end
        end
      end
    end

    def gain_evs(pkmn, foe)
      total = pkmn.ev.values.sum
      foe.species_data.evs.each do |stat, amount|
        next if amount <= 0
        amount = [amount, Pokemon::EV_STAT_LIMIT - pkmn.ev[stat], Pokemon::EV_LIMIT - total].min
        next if amount <= 0
        pkmn.ev[stat] += amount
        total += amount
      end
    end
  end
end
