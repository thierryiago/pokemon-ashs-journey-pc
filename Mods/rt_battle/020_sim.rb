#==============================================================================
# Batalha em tempo real — simulação (Ruby puro, sem RGSS)
#
# Guarda posições, golpes, projéteis, status e dano. A cena (030_scene.rb) lê
# o estado para desenhar e manda as entradas do jogador; a IA mora aqui.
# Coordenadas em pixels do mapa. Tempo em segundos.
#==============================================================================
module RTB
  STAGE_KEYS = [:atk, :def, :spa, :spd, :spe].freeze
  BURN_TICK  = 1.5   # dano de queimadura/veneno a cada 1,5 s
  DODGE_TIME = 0.22
  DODGE_DIST = 70.0
  DODGE_CD   = 1.0

  # Ajustes do 000_ash_journey.rb (1.0 quando o arquivo de config não existe, ex.: testes).
  def self.damage_scale
    defined?(AshJourney::RT_DAMAGE_SCALE) ? AshJourney::RT_DAMAGE_SCALE : 1.0
  end

  def self.time_scale
    defined?(AshJourney::RT_TIME_SCALE) ? AshJourney::RT_TIME_SCALE : 1.0
  end

  def self.anim_speed
    defined?(AshJourney::RT_ANIM_SPEED) ? AshJourney::RT_ANIM_SPEED : 1.0
  end

  def self.sprite_scale
    defined?(AshJourney::RT_SPRITE_SCALE) ? AshJourney::RT_SPRITE_SCALE : 1.0
  end

  # Raio de acerto acompanha o tamanho do sprite, até 15 px (cabe num corredor de 1 tile).
  def self.fighter_radius
    (12.0 * sprite_scale).clamp(12.0, 15.0)
  end

  def self.cooldown_scale
    defined?(AshJourney::RT_COOLDOWN_SCALE) ? AshJourney::RT_COOLDOWN_SCALE : 1.0
  end

  def self.stage_mult(s)
    s >= 0 ? (2.0 + s) / 2.0 : 2.0 / (2.0 - s)
  end

  #----------------------------------------------------------------------------
  # Um Pokémon em campo. pkmn é o Pokemon do jogo (ou um dublê nos testes).
  #----------------------------------------------------------------------------
  class Fighter
    attr_reader   :pkmn, :side, :cds, :stages, :timers, :recent, :combo
    attr_accessor :x, :y, :fx, :fy, :radius, :lock, :pending, :dash, :dodge,
                  :dodge_cd, :stun, :confuse, :dot_t, :invuln, :flash, :anim_t,
                  :ai, :hidden, :leech_by, :leech_t, :specs,
                  :sub_hp, :type_override, :last_slot, :last_spec, :semi, :age,
                  :protect_kind, :power_trick, :bind_t, :perish

    def initialize(pkmn, side, specs, x, y)
      @pkmn = pkmn; @side = side; @specs = specs
      @x = x.to_f; @y = y.to_f
      @fx = 0.0; @fy = (side == 0 ? -1.0 : 1.0)
      @radius = RTB.fighter_radius
      @cds = Array.new(specs.length, 0.0)
      @stages = Hash.new(0)
      @lock = 0.0; @pending = nil; @dash = nil; @dodge = nil; @dodge_cd = 0.0
      @stun = 0.0; @confuse = 0.0; @dot_t = 0.0; @invuln = 0.0; @flash = 0.0
      @anim_t = 0.0; @hidden = false; @leech_by = nil; @leech_t = 0.0
      @timers = Hash.new(0.0)   # efeitos com duração (s): :taunt, :bound, :magnet_rise...
      @recent = []              # danos recebidos: [hora, dano, categoria, lado de quem bateu]
      @combo = {}               # golpes em sequência (Fury Cutter, Rollout): id => [vezes, hora]
      @sub_hp = 0; @type_override = nil; @last_slot = nil; @last_spec = nil; @semi = nil
      @age = 0.0; @protect_kind = nil; @power_trick = false; @bind_t = 0.0; @perish = nil
      if pkmn.status == :SLEEP
        @stun = 3.0
      elsif pkmn.status == :FROZEN
        @stun = 3.0
      end
    end

    def name;     @pkmn.name;    end
    def level;    @pkmn.level;   end
    def hp;       @pkmn.hp;      end
    def totalhp;  @pkmn.totalhp; end
    def fainted?; @pkmn.hp <= 0; end
    def status;   @pkmn.status;  end
    def types
      return @type_override if @type_override
      t = @pkmn.types
      t.is_a?(Array) ? t : [t]
    end

    def type?(t)
      types.any? { |x| x.to_s == t.to_s }
    end

    def gender
      @pkmn.respond_to?(:gender) ? @pkmn.gender : 2
    end

    # Encostado no chão? (voador e Magnet Rise flutuam; Gravity derruba todo mundo)
    def grounded?(gravity = false)
      return true if gravity
      !type?(:FLYING) && @timers[:magnet_rise] <= 0 && @timers[:telekinesis] <= 0
    end

    def stat(key)
      key = { atk: :def, def: :atk }[key] || key if @power_trick
      base = case key
             when :atk then @pkmn.attack
             when :def then @pkmn.defense
             when :spa then @pkmn.spatk
             when :spd then @pkmn.spdef
             when :spe then @pkmn.speed
             end
      base * RTB.stage_mult(@stages[key])
    end

    # Velocidade de movimento em px/s. Usa o Speed base da espécie (e não o do
    # nível), para um Pokémon de nível baixo não ficar arrastado: base 20 anda
    # ~110 px/s, base 90 ~145, base 150 ~175 (o jogador anda ~128 px/s).
    def move_speed
      base = begin
        @pkmn.species_data.base_stats[:SPEED]
      rescue StandardError
        nil
      end
      v = base ? 100.0 + base * 0.5 : 70.0 + @pkmn.speed * 0.6
      v = 100.0 if v < 100.0
      v = 190.0 if v > 190.0
      v *= RTB.stage_mult(@stages[:spe]).clamp(0.5, 1.6)
      v *= 0.5 if status == :PARALYSIS
      v
    end

    def busy?
      @lock > 0 || @dash || @dodge || @stun > 0 || fainted? || @hidden
    end

    # Golpe que o slot usa agora: o próprio, ou Struggle sem PP em nenhum.
    def move_pp(slot)
      m = @pkmn.moves[slot]
      m ? m.pp : 0
    end

    def can_use?(slot)
      return false if busy? || slot >= @specs.length
      return false if @cds[slot] > 0
      move_pp(slot) > 0 || all_out_of_pp?
    end

    def all_out_of_pp?
      (0...@specs.length).all? { |i| move_pp(i) <= 0 }
    end
  end

  Projectile = Struct.new(:owner, :spec, :x, :y, :vx, :vy, :dist, :max, :r, :dead, :homing,
                          keyword_init: true)
  # Armadilha no chão (Spikes, Toxic Spikes, Stealth Rock, Sticky Web). side = quem jogou.
  Hazard = Struct.new(:kind, :side, :x, :y, :r, :t, :type, keyword_init: true)
  Effect = Struct.new(:kind, :x, :y, :x2, :y2, :r, :t, :max, :type, :spec, keyword_init: true)

  #----------------------------------------------------------------------------
  # Simulação
  #----------------------------------------------------------------------------
  class Sim
    attr_reader :fighters, :projectiles, :effects, :events, :arena, :time,
                :weather, :weather_t, :terrain, :terrain_t, :side_fx, :field, :hazards
    attr_accessor :frozen, :spec_lookup, :random_spec

    # arena: [x0, y0, x1, y1] em pixels. walkable: ->(px, py) { true/false } (a pé).
    # flyable: ->(px, py) por onde os projéteis passam (padrão: walkable).
    # crossable: ->(tx1, ty1, tx2, ty2) dá para passar entre dois tiles vizinhos? (cercas
    # e muros que bloqueiam só um lado do tile). Padrão: sempre.
    # type_mult: ->(move_type, [tipos do alvo]) { multiplicador }
    # spec_lookup: ->(move_id, side) { spec } e random_spec: ->(side) { spec } servem para
    # golpes que chamam outros (Metronome, Nature Power...). Sem eles, esses golpes falham.
    def initialize(arena:, walkable:, type_mult:, rng: Random.new, ai_level: 0,
                   flyable: nil, crossable: nil, spec_lookup: nil, random_spec: nil)
      @arena = arena; @walkable = walkable; @type_mult = type_mult; @rng = rng
      @flyable = flyable || walkable
      @crossable = crossable
      @ai_level = ai_level
      @fighters = []; @projectiles = []; @effects = []; @events = []
      @time = 0.0; @frozen = false
      @spec_lookup = spec_lookup; @random_spec = random_spec
      @weather = nil; @weather_t = 0.0; @terrain = nil; @terrain_t = 0.0
      @side_fx = [Hash.new(0.0), Hash.new(0.0)]   # telas, Safeguard, Tailwind... por lado
      @field = Hash.new(0.0)                       # Gravity, Trick Room, Mud Sport...
      @hazards = []
      @last_spec = nil; @field_tick = 0.0
    end

    def add(fighter)
      @fighters.push(fighter)
      on_enter(fighter)
      fighter
    end

    def remove(fighter)
      @fighters.delete(fighter)
      @projectiles.each { |p| p.dead = true if p.owner == fighter }
    end

    def active(side)
      @fighters.find { |f| f.side == side && !f.fainted? && !f.hidden }
    end

    def emit(*ev)
      @events.push(ev)
    end

    def rand_f
      @rng.rand
    end

    # inputs: { 0 => {mx:, my:, use: slot|nil, dodge: bool} } (o lado 1 usa IA se não vier entrada)
    def update(dt, inputs = {})
      @time += dt
      return if @frozen
      @fighters.dup.each do |f|
        next if f.fainted? || f.hidden
        tick_timers(f, dt)
        next if f.fainted?   # pode ter caído por veneno/queimadura/semente agora
        input = inputs[f.side] || ai_input(f, dt)
        step_fighter(f, input, dt)
      end
      separate_fighters
      step_projectiles(dt)
      step_field(dt)
      @effects.each { |e| e.t += dt }
      @effects.reject! { |e| e.t >= e.max }
    end

    #--------------------------------------------------------------------------
    def tick_timers(f, dt)
      f.cds.each_index { |i| f.cds[i] -= dt if f.cds[i] > 0 }
      f.dodge_cd -= dt if f.dodge_cd > 0
      f.invuln -= dt if f.invuln > 0
      f.flash -= dt if f.flash > 0
      f.confuse -= dt if f.confuse > 0
      f.anim_t += dt
      f.age += dt
      tick_effects(f, dt)
      if f.stun > 0
        f.stun -= dt
        if f.stun <= 0 && [:SLEEP, :FROZEN].include?(f.status)
          emit(:text, f, f.status == :SLEEP ? "acordou" : "descongelou")
          f.pkmn.status = :NONE
        end
      end
      if f.leech_by
        f.leech_t += dt
        if f.leech_t >= BURN_TICK
          f.leech_t -= BURN_TICK
          dmg = [f.totalhp / 16, 1].max
          apply_damage(f, dmg, nil, 1.0, false)
          seeder = active(f.leech_by)
          heal(seeder, dmg) if seeder
        end
      end
      if [:BURN, :POISON].include?(f.status)
        f.dot_t += dt
        if f.dot_t >= BURN_TICK
          f.dot_t -= BURN_TICK
          dmg = [f.totalhp / 16, 1].max
          apply_damage(f, dmg, nil, 1.0, false)
        end
      end
    end

    def step_fighter(f, input, dt)
      # Avanço (dash) e esquiva movem sozinhos
      if f.dodge
        f.dodge[:t] += dt
        move_by(f, f.dodge[:dx] * DODGE_DIST / DODGE_TIME * dt, f.dodge[:dy] * DODGE_DIST / DODGE_TIME * dt)
        f.dodge = nil if f.dodge[:t] >= DODGE_TIME
        return
      end
      if f.dash
        d = f.dash
        d[:t] += dt
        spd = d[:spec].range / 0.2
        move_by(f, f.fx * spd * dt, f.fy * spd * dt)
        foe = opponent(f)
        if foe && !d[:hit] && dist(f, foe) <= f.radius + foe.radius + 6
          d[:hit] = true
          emit(:anim, f, d[:spec], f.x, f.y, foe.x, foe.y, :full)
          hit(f, foe, d[:spec])
        end
        if d[:t] >= 0.2
          f.dash = nil
          crash(f, d[:spec]) unless d[:hit]
        end
        return
      end
      if f.lock > 0
        f.lock -= dt
        if f.lock <= 0 && f.pending
          spec, slot, point = f.pending
          f.pending = nil
          release(f, spec, slot, point)
        end
        return
      end
      if f.stun > 0
        # Sleep Talk e Snore funcionam dormindo
        slot = input[:use]
        start_move(f, slot) if slot && f.status == :SLEEP && sleep_usable?(f, slot)
        return
      end
      # Esquiva (presa por Wrap/Bind, sob Gravity ou Telekinesis não dá)
      if input[:dodge] && f.dodge_cd <= 0 && can_dodge?(f)
        dx, dy = norm(input[:mx].to_f, input[:my].to_f)
        dx, dy = f.fx, f.fy if dx == 0 && dy == 0
        f.dodge = { t: 0.0, dx: dx, dy: dy }
        f.invuln = DODGE_TIME + 0.05
        f.dodge_cd = DODGE_CD
        emit(:dodge, f)
        return
      end
      # Movimento
      mx = input[:mx].to_f; my = input[:my].to_f
      if f.confuse > 0 && f.side == 0
        mx = -mx; my = -my
      end
      if mx != 0 || my != 0
        nx, ny = norm(mx, my)
        (f.fx = nx; f.fy = ny) unless input[:face]
        sp = move_speed_of(f)
        move_by(f, nx * sp * dt, ny * sp * dt) if f.timers[:bound] <= 0
      end
      if input[:face]
        f.fx, f.fy = norm(*input[:face])
      end
      # Golpe
      slot = input[:use]
      start_move(f, slot) if slot && f.can_use?(slot)
    end

    def start_move(f, slot)
      spec = f.specs[slot]
      if f.move_pp(slot) <= 0
        spec = RTB.struggle_spec
      else
        f.pkmn.moves[slot].pp -= 1
      end
      f.cds[slot] = spec.cooldown * RTB.cooldown_scale
      f.cds[slot] *= 1.25 if f.status == :PARALYSIS
      f.cds[slot] *= 0.75 if @side_fx[f.side][:tailwind] > 0
      f.last_slot = slot
      return unless move_allowed?(f, spec, slot)
      aim_assist(f, spec)
      f.lock = windup_of(f, spec)
      f.pending = [spec, slot]
      if spec.effect && spec.effect[:semi]
        f.semi = spec.effect[:semi]
        emit(:text, f, SEMI_TEXT[f.semi])
      end
      if spec.kind == :strike
        # O golpe cai num ponto: o alvo (se estiver na mira e no alcance) ou o fim do alcance.
        foe = opponent(f)
        d = foe ? dist(f, foe) : spec.range
        d = spec.range if d > spec.range || (foe && facing_dot(f, foe) < 0.8)
        px = f.x + f.fx * d; py = f.y + f.fy * d
        f.pending = [spec, slot, [px, py]]
        add_effect(:telegraph, px, py, r: spec.width, max: f.lock, type: spec.type, spec: spec) unless f.semi
      end
      emit(:windup, f, spec)
    end

    # Ajuda na mira: se o alvo estiver até ~45° da direção, mira nele (com 8 direções,
    # isso cobre o espaço entre uma direção e a vizinha).
    def aim_assist(f, spec)
      foe = opponent(f)
      return unless foe
      return if [:buff, :noop, :pulse, :debuff].include?(spec.kind)
      dx, dy = norm(foe.x - f.x, foe.y - f.y)
      dx, dy = -dx, -dy if f.confuse > 0 && f.side == 1
      if dx * f.fx + dy * f.fy > 0.7 || f.timers[:lock_on] > 0 || (spec.effect || {})[:homing]
        f.fx = dx; f.fy = dy
      end
    end

    def release(f, spec, slot, point = nil, depth = 0)
      foe = opponent(f)
      eff = spec.effect || {}
      if eff[:call]
        called = resolve_call(f, spec, slot)
        return release(f, called, slot, nil, depth + 1) if called && depth < 2
        emit(:text, f, "Mas falhou!")
        return
      end
      f.semi = nil
      remember_use(f, spec)
      emit(:use, f, spec)
      return if before_release(f, spec, foe)
      case spec.kind
      when :strike
        px, py = point || [f.x + f.fx * spec.range, f.y + f.fy * spec.range]
        if foe && (eff[:semi] || eff[:delayed]) && dist(f, foe) <= spec.range + 40
          px, py = foe.x, foe.y   # quem voa/cava cai em cima do alvo
        end
        add_effect(:puff, px, py, r: spec.width, max: 0.25, type: spec.type, spec: spec)
        emit(:anim, f, spec, f.x, f.y, px, py, :full)
        hit(f, foe, spec) if foe && Math.hypot(foe.x - px, foe.y - py) <= spec.width + foe.radius
      when :melee
        cx = f.x + f.fx * (f.radius + spec.range / 2)
        cy = f.y + f.fy * (f.radius + spec.range / 2)
        add_effect(:slash, cx, cy, r: spec.range / 2 + 6, max: 0.18, type: spec.type, spec: spec)
        if foe && dist(f, foe) <= f.radius + foe.radius + spec.range &&
           facing_dot(f, foe) > 0.25
          emit(:anim, f, spec, f.x, f.y, foe.x, foe.y, :full)
          hit(f, foe, spec)
        else
          emit(:anim, f, spec, f.x, f.y, f.x + f.fx * 40, f.y + f.fy * 40, :full)
        end
      when :dash
        f.dash = { t: 0.0, spec: spec, hit: false }
      when :projectile, :status
        homing = eff[:homing] || f.timers[:lock_on] > 0
        @projectiles.push(Projectile.new(owner: f, spec: spec,
                                         x: f.x + f.fx * f.radius, y: f.y + f.fy * f.radius,
                                         vx: f.fx * spec.speed, vy: f.fy * spec.speed,
                                         dist: 0.0, max: spec.range, r: spec.width.to_f, dead: false,
                                         homing: homing))
      when :hazard
        d = foe && facing_dot(f, foe) > 0.5 ? [dist(f, foe), spec.range].min : spec.range * 0.7
        lay_hazard(f, spec, f.x + f.fx * d, f.y + f.fy * d)
      when :beam
        len = ray_length(f.x, f.y, f.fx, f.fy, spec.range)
        x2 = f.x + f.fx * len; y2 = f.y + f.fy * len
        add_effect(:beam, f.x, f.y, x2: x2, y2: y2, r: spec.width, max: 0.3, type: spec.type, spec: spec)
        hit_beam = foe && seg_dist(foe.x, foe.y, f.x, f.y, x2, y2) <= spec.width + foe.radius
        tx, ty = hit_beam ? [foe.x, foe.y] : [f.x + f.fx * len * 0.6, f.y + f.fy * len * 0.6]
        emit(:anim, f, spec, f.x, f.y, tx, ty, :full)
        hit(f, foe, spec) if hit_beam
      when :pulse, :debuff
        add_effect(:ring, f.x, f.y, r: spec.range, max: 0.35, type: spec.type, spec: spec)
        reach = foe && dist(f, foe) <= spec.range + foe.radius
        tx, ty = reach ? [foe.x, foe.y] : [f.x + f.fx * 40, f.y + f.fy * 40]
        emit(:anim, f, spec, f.x, f.y, tx, ty, :full)
        hit(f, foe, spec) if reach
      when :buff
        add_effect(:aura, f.x, f.y, r: f.radius + 10, max: 0.5, type: spec.type, spec: spec)
        tx, ty = foe ? [foe.x, foe.y] : [f.x, f.y - 40]
        emit(:anim, f, spec, f.x, f.y, tx, ty, :full)
        apply_self_effect(f, spec)
      when :noop
        emit(:text, f, "#{spec.name}: ainda sem efeito no tempo real")
      end
      f.timers[:lock_on] = 0 if spec.power.to_i > 0
      after_release(f, spec, foe)
    end

    #--------------------------------------------------------------------------
    # Acerto: dano + efeitos secundários
    #--------------------------------------------------------------------------
    def hit(att, dfn, spec)
      return if dfn.fainted?
      eff = spec.effect || {}
      return unless hit_allowed?(att, dfn, spec)
      behind_sub = dfn.sub_hp > 0 && !sound?(spec)
      if spec.power.to_i > 0 || eff[:fixed] || eff[:counter] || eff[:ohko]
        mult = type_mult_for(att, dfn, spec)
        if mult == 0
          emit(:text, dfn, "não afeta")
          return
        end
        hits = eff[:hits] || 1
        crit = crit_roll(att, dfn, spec)
        total = 0
        hits.times { total += calc_damage(att, dfn, spec, mult, crit) }
        total = special_damage(att, dfn, spec, total)
        return if total.nil?
        total = absorb_substitute(dfn, total, spec)
        apply_damage(dfn, total, att, mult, crit, spec) if total > 0
        if eff[:recoil] && total > 0
          apply_damage(att, [(total * eff[:recoil]).floor, 1].max, nil, 1.0, false)
        end
        if eff[:drain] && total > 0
          heal(att, (total * eff[:drain]).floor)
        end
        if dfn.status == :FROZEN && spec.type.to_s == "FIRE"
          dfn.pkmn.status = :NONE; dfn.stun = 0
          emit(:text, dfn, "descongelou")
        end
      end
      after_hit(att, dfn, spec)
      if !dfn.fainted? && !behind_sub
        apply_target_effect(att, dfn, spec)
      elsif behind_sub && spec.power.to_i == 0
        emit(:text, dfn, "o substituto bloqueou")
      end
      if spec.kind != :buff && eff[:user_stages] && spec.power.to_i > 0 &&
         rand_f * 100 < (eff[:self_chance] || 100)
        apply_stages(att, eff[:user_stages], att)
      end
    end

    def calc_damage(att, dfn, spec, mult, crit)
      eff = spec.effect || {}
      return fixed_damage(att, dfn, eff[:fixed]) if eff[:fixed]
      return 0 if eff[:counter] || eff[:ohko]
      physical = (spec.category == 0)
      a, d = attack_defense(att, dfn, spec, physical, crit)
      d = 1.0 if d < 1
      power = power_for(att, dfn, spec)
      base = (((2.0 * att.level / 5 + 2) * power * a / d) / 50.0) + 2
      base *= 1.5 if att.type?(spec.type)
      base *= mult
      base *= 1.5 if crit
      base *= 0.5 if physical && att.status == :BURN && !(eff[:power_fn] == :facade)
      base *= field_mult(att, dfn, spec, physical, crit)
      base *= (85 + @rng.rand(16)) / 100.0
      base *= RTB.damage_scale
      [base.floor, 1].max
    end

    def apply_damage(f, dmg, by, mult, crit, spec = nil)
      return if f.fainted?
      dmg = f.hp if dmg > f.hp
      if by && f.timers[:endure] > 0 && dmg >= f.hp
        dmg = f.hp - 1
        emit(:text, f, "aguentou!")
      end
      dmg = f.hp - 1 if by && spec && (spec.effect || {})[:false_swipe] && dmg >= f.hp
      return if dmg <= 0
      f.recent.push([@time, dmg, spec ? spec.category : nil, by ? by.side : nil])
      f.recent.shift while f.recent.length > 8
      f.pkmn.hp -= dmg
      f.flash = 0.2
      f.stun = 0 if f.status == :SLEEP && by   # dano direto acorda
      emit(:damage, f, dmg, mult, crit)
      if f.pending && f.pending[0].effect && f.pending[0].effect[:focus_punch] && by
        f.lock = 0; f.pending = nil
        emit(:text, f, "perdeu a concentração!")
      end
      if f.fainted?
        f.pkmn.hp = 0
        f.pkmn.status = :NONE if f.pkmn.respond_to?(:status=)
        f.lock = 0; f.pending = nil; f.dash = nil; f.semi = nil
        emit(:faint, f)
        on_faint(f, by)
      end
    end

    def heal(f, amount)
      return if f.fainted? || amount <= 0
      if f.timers[:heal_block] > 0
        emit(:text, f, "não pode se curar")
        return
      end
      amount = f.totalhp - f.hp if f.hp + amount > f.totalhp
      f.pkmn.hp += amount
      emit(:heal, f, amount)
    end

    def apply_target_effect(att, dfn, spec)
      eff = spec.effect || {}
      chance = eff[:chance] || 100
      return if rand_f * 100 >= chance
      return if eff[:if_poisoned] && dfn.status != :POISON
      if eff[:gender_only] && !(att.gender < 2 && dfn.gender < 2 && att.gender != dfn.gender)
        emit(:text, dfn, "não afeta")
        return
      end
      if eff[:status]
        st = eff[:status] == :TRI ? [:BURN, :PARALYSIS, :FROZEN][@rng.rand(3)] : eff[:status]
        set_status(dfn, st, spec)
      end
      flinch(dfn) if eff[:flinch] && spec.power.to_i > 0
      more_target_effects(att, dfn, spec)
      if eff[:leech]
        if dfn.types.map(&:to_s).include?("GRASS")
          emit(:text, dfn, "não afeta")
        else
          dfn.leech_by = att.side
          emit(:text, dfn, "foi semeado!")
        end
      end
      emit(:force_out, dfn) if eff[:force_out]
      apply_stages(dfn, eff[:target_stages], att) if eff[:target_stages]
    end

    # Muda atributos (Mist protege das quedas causadas pelo adversário).
    def apply_stages(f, stages, by)
      if by && by.side != f.side && @side_fx[f.side][:mist] > 0 && stages.values.any?(&:negative?)
        emit(:text, f, "a névoa protegeu")
        stages = stages.select { |_, v| v > 0 }
        return if stages.empty?
      end
      stages.each { |k, v| f.stages[k] = (f.stages[k] + v).clamp(-6, 6) }
      emit(:stages, f, stages)
    end

    def apply_self_effect(f, spec)
      eff = spec.effect || {}
      apply_stages(f, eff[:user_stages], f) if eff[:user_stages]
      heal(f, (f.totalhp * heal_frac(eff)).floor) if eff[:heal]
      if eff[:rest]
        f.pkmn.status = :SLEEP
        f.stun = 3.0
        emit(:status, f, :SLEEP)
      end
      if eff[:protect]
        f.invuln = [f.invuln, eff[:protect]].max
        f.timers[:protect] = eff[:protect]
        f.protect_kind = eff[:protect_kind]
        emit(:text, f, "se protegeu!")
      end
      if eff[:haze]
        @fighters.each { |x| x.stages.clear }
        emit(:text, f, "atributos de todos voltaram ao normal")
      end
      if eff[:flee]
        f.timers[:trapped] > 0 ? emit(:text, f, "está preso!") : emit(:flee, f)
      end
      more_self_effects(f, spec)
    end

    IMMUNE = {
      BURN: ["FIRE"], FROZEN: ["ICE"], PARALYSIS: ["ELECTRIC"],
      POISON: ["POISON", "STEEL"]
    }

    def set_status(f, status, spec)
      return unless status_allowed?(f, status)
      if status == :CONFUSED
        f.confuse = 4.0
        emit(:status, f, :CONFUSED)
        return
      end
      return if f.status != :NONE && !f.status.nil?
      return if (IMMUNE[status] || []).any? { |t| f.types.map(&:to_s).include?(t) }
      return if status == :PARALYSIS && spec && spec.type.to_s == "ELECTRIC" && f.type?(:GROUND)
      f.pkmn.status = status
      f.pkmn.statusCount = 0 if f.pkmn.respond_to?(:statusCount=)
      case status
      when :SLEEP  then f.stun = 2.5 + rand_f * 1.5
      when :FROZEN then f.stun = 3.0
      end
      f.lock = 0; f.pending = nil
      emit(:status, f, status)
    end

    #--------------------------------------------------------------------------
    # Projéteis
    #--------------------------------------------------------------------------
    def step_projectiles(dt)
      @projectiles.each do |p|
        next if p.dead
        steer(p, dt) if p.homing
        sx = p.vx * dt; sy = p.vy * dt
        p.x += sx; p.y += sy
        p.dist += Math.sqrt(sx * sx + sy * sy)
        if p.dist >= p.max || !inside_arena?(p.x, p.y) || !@flyable.call(p.x, p.y)
          p.dead = true
          add_effect(:puff, p.x, p.y, r: p.r + 4, max: 0.15, type: p.spec.type, spec: p.spec)
          next
        end
        @fighters.each do |f|
          next if f.side == p.owner.side || f.fainted? || f.hidden
          next if Math.hypot(f.x - p.x, f.y - p.y) > f.radius + p.r
          p.dead = true
          add_effect(:puff, p.x, p.y, r: p.r + 8, max: 0.2, type: p.spec.type, spec: p.spec)
          emit(:anim, p.owner, p.spec, p.owner.x, p.owner.y, f.x, f.y, :target)
          hit(p.owner, f, p.spec)
          break
        end
      end
      @projectiles.reject!(&:dead)
    end

    #--------------------------------------------------------------------------
    # IA (Pokémon selvagens e, depois, treinadores)
    #--------------------------------------------------------------------------
    def ai_input(f, dt)
      foe = opponent(f)
      return { mx: 0, my: 0 } unless foe
      f.ai ||= { think: 0.0, strafe: 1, strafe_t: 0.0, want: nil, dodged: {} }
      ai = f.ai
      ai[:think] -= dt
      ai[:strafe_t] -= dt
      if ai[:strafe_t] <= 0
        ai[:strafe] = (rand_f < 0.5 ? -1 : 1)
        ai[:strafe_t] = 0.8 + rand_f * 1.2
      end
      dx = foe.x - f.x; dy = foe.y - f.y
      d = Math.hypot(dx, dy)
      ux, uy = norm(dx, dy)
      ux, uy = -ux, -uy if f.confuse > 0
      # Escolhe o próximo golpe de tempos em tempos
      if ai[:think] <= 0
        ai[:think] = 0.35
        ai[:want] = pick_move(f, foe)
      end
      slot = ai[:want]
      spec = slot ? f.specs[slot] : nil
      want_d = case spec && spec.kind
               when :melee, :dash then f.radius + foe.radius + 10
               when :pulse, :debuff then 55
               when :projectile, :status, :strike, :hazard then 150
               when :beam then 190
               else 120
               end
      mx = 0.0; my = 0.0
      blocked = !line_clear?(f.x, f.y, foe.x, foe.y)
      if blocked || d > want_d + 18
        mx, my = blocked ? path_dir(f, foe, ux, uy) : [ux, uy]
      elsif d < want_d - 25
        mx, my = -ux, -uy
      else
        mx, my = -uy * ai[:strafe] * 0.7, ux * ai[:strafe] * 0.7
      end
      input = { mx: mx, my: my, face: [ux, uy] }
      # Desvia de projéteis que vêm na direção dele
      dodge_chance = [0.06, 0.2, 0.4][@ai_level] || 0.06
      @projectiles.each do |p|
        next if p.owner.side == f.side || ai[:dodged][p.object_id]
        next if Math.hypot(p.x - f.x, p.y - f.y) > 80
        ai[:dodged][p.object_id] = true
        if rand_f < dodge_chance
          input[:dodge] = true
          input[:mx], input[:my] = -p.vy, p.vx
        end
      end
      if slot && f.can_use?(slot)
        reach = case spec.kind
                when :melee then f.radius + foe.radius + spec.range
                when :dash then spec.range + foe.radius
                when :pulse, :debuff then spec.range + foe.radius
                when :buff, :noop then 99_999
                else spec.range * 0.9
                end
        if d <= reach
          input[:use] = slot
          ai[:want] = nil
          ai[:think] = 0.4 + rand_f * 0.5
        end
      end
      input
    end

    def pick_move(f, foe)
      best = nil; best_score = -1
      f.specs.each_with_index do |spec, i|
        next if f.cds[i] > 0 || (f.move_pp(i) <= 0 && !f.all_out_of_pp?)
        score = ai_score(f, foe, spec)
        score *= 0.6 + rand_f * 0.8
        next if score <= 0
        if score > best_score
          best = i; best_score = score
        end
      end
      best
    end

    # Dá para andar em linha reta entre os dois pontos? (amostra a cada 8 px)
    def line_clear?(x1, y1, x2, y2)
      n = (Math.hypot(x2 - x1, y2 - y1) / 8).ceil
      prev = tile_of(x1, y1)
      (1...n).all? do |i|
        t = i.to_f / n
        x = x1 + (x2 - x1) * t; y = y1 + (y2 - y1) * t
        cur = tile_of(x, y)
        ok = @walkable.call(x, y) && step_crossable?(prev, cur)
        prev = cur
        ok
      end
    end

    # Até onde um feixe chega antes de bater numa parede (passa por cima de água etc.).
    def ray_length(x, y, dx, dy, range)
      d = 8.0
      while d <= range
        px = x + dx * d; py = y + dy * d
        return [d - 8, 0].max.to_f unless inside_arena?(px, py) && @flyable.call(px, py)
        d += 8
      end
      range.to_f
    end

    def tile_of(x, y)
      [(x / 32).floor, (y / 32).floor]
    end

    # Passa de um tile para outro (vizinho, inclusive na diagonal)?
    def step_crossable?(a, b)
      return true if !@crossable || a == b
      if a[0] != b[0] && a[1] != b[1]
        # diagonal: vale se um dos dois caminhos em L estiver livre
        m1 = [b[0], a[1]]; m2 = [a[0], b[1]]
        return (@walkable.call(m1[0] * 32 + 16, m1[1] * 32 + 16) && step_crossable?(a, m1) && step_crossable?(m1, b)) ||
               (@walkable.call(m2[0] * 32 + 16, m2[1] * 32 + 16) && step_crossable?(a, m2) && step_crossable?(m2, b))
      end
      return false if (a[0] - b[0]).abs > 1 || (a[1] - b[1]).abs > 1
      @crossable.call(a[0], a[1], b[0], b[1])
    end

    # Direção do próximo passo pelo caminho mais curto em tiles (BFS), refeito a cada 0,4 s.
    def path_dir(f, foe, ux, uy)
      ai = f.ai
      if !ai[:path_t] || ai[:path_t] <= @time
        ai[:path_t] = @time + 0.4
        ai[:path] = bfs_next(f.x, f.y, foe.x, foe.y)
      end
      nxt = ai[:path]
      return [ux, uy] unless nxt
      norm(nxt[0] * 32 + 16 - f.x, nxt[1] * 32 + 16 - f.y)
    end

    def bfs_next(x1, y1, x2, y2)
      start = [(x1 / 32).floor, (y1 / 32).floor]
      goal = [(x2 / 32).floor, (y2 / 32).floor]
      return nil if start == goal
      tx0 = (@arena[0] / 32); ty0 = (@arena[1] / 32)
      tx1 = (@arena[2] / 32); ty1 = (@arena[3] / 32)
      prev = { start => nil }
      queue = [start]
      until queue.empty?
        cur = queue.shift
        break if cur == goal
        [[1, 0], [-1, 0], [0, 1], [0, -1]].each do |dx, dy|
          n = [cur[0] + dx, cur[1] + dy]
          next if prev.key?(n) || n[0] < tx0 || n[0] > tx1 || n[1] < ty0 || n[1] > ty1
          next unless n == goal || @walkable.call(n[0] * 32 + 16, n[1] * 32 + 16)
          next unless step_crossable?(cur, n)
          prev[n] = cur
          queue.push(n)
        end
      end
      return nil unless prev.key?(goal)
      step = goal
      step = prev[step] while prev[step] && prev[step] != start
      step
    end

    #--------------------------------------------------------------------------
    # Geometria
    #--------------------------------------------------------------------------
    def opponent(f)
      active(1 - f.side)
    end

    def dist(a, b)
      Math.hypot(a.x - b.x, a.y - b.y)
    end

    def facing_dot(f, t)
      dx, dy = norm(t.x - f.x, t.y - f.y)
      dx * f.fx + dy * f.fy
    end

    def norm(x, y)
      l = Math.sqrt(x * x + y * y)
      l > 0 ? [x / l, y / l] : [0.0, 0.0]
    end

    def seg_dist(px, py, x1, y1, x2, y2)
      vx = x2 - x1; vy = y2 - y1
      l2 = vx * vx + vy * vy
      t = l2 > 0 ? (((px - x1) * vx + (py - y1) * vy) / l2).clamp(0.0, 1.0) : 0.0
      Math.hypot(px - (x1 + t * vx), py - (y1 + t * vy))
    end

    def inside_arena?(x, y)
      x >= @arena[0] && y >= @arena[1] && x <= @arena[2] && y <= @arena[3]
    end

    # Pode ficar com o centro em (x, y)? Confere os quatro lados do círculo.
    def free?(f, x, y)
      r = f.radius - 2
      return false unless inside_arena?(x - r, y - r) && inside_arena?(x + r, y + r)
      @walkable.call(x - r, y) && @walkable.call(x + r, y) &&
        @walkable.call(x, y - r) && @walkable.call(x, y + r)
    end

    def move_by(f, dx, dy)
      f.x += dx if free?(f, f.x + dx, f.y) && edges_ok?(f, f.x, f.y, f.x + dx, f.y)
      f.y += dy if free?(f, f.x, f.y + dy) && edges_ok?(f, f.x, f.y, f.x, f.y + dy)
    end

    # Nenhum ponto do círculo atravessa um lado de tile bloqueado (cerca, muro baixo)?
    def edges_ok?(f, x0, y0, x1, y1)
      return true unless @crossable
      r = f.radius - 2
      [[0, 0], [-r, 0], [r, 0], [0, -r], [0, r]].all? do |ox, oy|
        step_crossable?(tile_of(x0 + ox, y0 + oy), tile_of(x1 + ox, y1 + oy))
      end
    end

    def separate_fighters
      list = @fighters.reject { |f| f.fainted? || f.hidden }
      list.combination(2).each do |a, b|
        d = dist(a, b)
        min = a.radius + b.radius
        next if d >= min || d == 0
        push = (min - d) / 2
        nx, ny = norm(b.x - a.x, b.y - a.y)
        move_by(a, -nx * push, -ny * push)
        move_by(b, nx * push, ny * push)
      end
    end

    def add_effect(kind, x, y, r: 0, max: 0.2, x2: nil, y2: nil, type: nil, spec: nil)
      @effects.push(Effect.new(kind: kind, x: x, y: y, x2: x2, y2: y2, r: r, t: 0.0,
                               max: max, type: type, spec: spec))
    end
  end
end
