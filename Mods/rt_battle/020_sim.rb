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
    attr_reader   :pkmn, :side, :specs, :cds, :stages
    attr_accessor :x, :y, :fx, :fy, :radius, :lock, :pending, :dash, :dodge,
                  :dodge_cd, :stun, :confuse, :dot_t, :invuln, :flash, :anim_t,
                  :ai, :hidden, :leech_by, :leech_t

    def initialize(pkmn, side, specs, x, y)
      @pkmn = pkmn; @side = side; @specs = specs
      @x = x.to_f; @y = y.to_f
      @fx = 0.0; @fy = (side == 0 ? -1.0 : 1.0)
      @radius = 12.0
      @cds = Array.new(specs.length, 0.0)
      @stages = Hash.new(0)
      @lock = 0.0; @pending = nil; @dash = nil; @dodge = nil; @dodge_cd = 0.0
      @stun = 0.0; @confuse = 0.0; @dot_t = 0.0; @invuln = 0.0; @flash = 0.0
      @anim_t = 0.0; @hidden = false; @leech_by = nil; @leech_t = 0.0
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
    def types;    t = @pkmn.types; t.is_a?(Array) ? t : [t]; end

    def stat(key)
      base = case key
             when :atk then @pkmn.attack
             when :def then @pkmn.defense
             when :spa then @pkmn.spatk
             when :spd then @pkmn.spdef
             when :spe then @pkmn.speed
             end
      base * RTB.stage_mult(@stages[key])
    end

    # Velocidade de movimento em px/s, a partir do atributo Speed.
    def move_speed
      v = 70.0 + @pkmn.speed * 0.6
      v = 70.0 if v < 70.0
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

  Projectile = Struct.new(:owner, :spec, :x, :y, :vx, :vy, :dist, :max, :r, :dead,
                          keyword_init: true)
  Effect = Struct.new(:kind, :x, :y, :x2, :y2, :r, :t, :max, :type, keyword_init: true)

  #----------------------------------------------------------------------------
  # Simulação
  #----------------------------------------------------------------------------
  class Sim
    attr_reader :fighters, :projectiles, :effects, :events, :arena, :time
    attr_accessor :frozen

    # arena: [x0, y0, x1, y1] em pixels. walkable: ->(px, py) { true/false }.
    # type_mult: ->(move_type, [tipos do alvo]) { multiplicador }
    def initialize(arena:, walkable:, type_mult:, rng: Random.new, ai_level: 0)
      @arena = arena; @walkable = walkable; @type_mult = type_mult; @rng = rng
      @ai_level = ai_level
      @fighters = []; @projectiles = []; @effects = []; @events = []
      @time = 0.0; @frozen = false
    end

    def add(fighter)
      @fighters.push(fighter)
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
        input = inputs[f.side] || ai_input(f, dt)
        step_fighter(f, input, dt)
      end
      separate_fighters
      step_projectiles(dt)
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
          hit(f, foe, d[:spec])
        end
        f.dash = nil if d[:t] >= 0.2
        return
      end
      if f.lock > 0
        f.lock -= dt
        if f.lock <= 0 && f.pending
          spec, slot = f.pending
          f.pending = nil
          release(f, spec, slot)
        end
        return
      end
      return if f.stun > 0
      # Esquiva
      if input[:dodge] && f.dodge_cd <= 0
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
        sp = f.move_speed
        move_by(f, nx * sp * dt, ny * sp * dt)
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
      aim_assist(f, spec)
      f.lock = spec.windup
      f.pending = [spec, slot]
      emit(:windup, f, spec)
    end

    # Ajuda na mira: se o alvo estiver até ~35° da direção, mira nele.
    def aim_assist(f, spec)
      foe = opponent(f)
      return unless foe
      return if [:buff, :noop, :pulse, :debuff].include?(spec.kind)
      dx, dy = norm(foe.x - f.x, foe.y - f.y)
      dx, dy = -dx, -dy if f.confuse > 0 && f.side == 1
      if dx * f.fx + dy * f.fy > 0.8
        f.fx = dx; f.fy = dy
      end
    end

    def release(f, spec, slot)
      foe = opponent(f)
      emit(:use, f, spec)
      case spec.kind
      when :melee
        cx = f.x + f.fx * (f.radius + spec.range / 2)
        cy = f.y + f.fy * (f.radius + spec.range / 2)
        add_effect(:slash, cx, cy, r: spec.range / 2 + 6, max: 0.18, type: spec.type)
        if foe && dist(f, foe) <= f.radius + foe.radius + spec.range &&
           facing_dot(f, foe) > 0.25
          hit(f, foe, spec)
        end
      when :dash
        f.dash = { t: 0.0, spec: spec, hit: false }
      when :projectile, :status
        @projectiles.push(Projectile.new(owner: f, spec: spec,
                                         x: f.x + f.fx * f.radius, y: f.y + f.fy * f.radius,
                                         vx: f.fx * spec.speed, vy: f.fy * spec.speed,
                                         dist: 0.0, max: spec.range, r: spec.width.to_f, dead: false))
      when :beam
        x2 = f.x + f.fx * spec.range; y2 = f.y + f.fy * spec.range
        add_effect(:beam, f.x, f.y, x2: x2, y2: y2, r: spec.width, max: 0.3, type: spec.type)
        if foe && seg_dist(foe.x, foe.y, f.x, f.y, x2, y2) <= spec.width + foe.radius
          hit(f, foe, spec)
        end
      when :pulse, :debuff
        add_effect(:ring, f.x, f.y, r: spec.range, max: 0.35, type: spec.type)
        hit(f, foe, spec) if foe && dist(f, foe) <= spec.range + foe.radius
      when :buff
        add_effect(:aura, f.x, f.y, r: f.radius + 10, max: 0.5, type: spec.type)
        apply_self_effect(f, spec)
      when :noop
        emit(:text, f, "#{spec.name}: ainda sem efeito no tempo real")
      end
    end

    #--------------------------------------------------------------------------
    # Acerto: dano + efeitos secundários
    #--------------------------------------------------------------------------
    def hit(att, dfn, spec)
      return if dfn.fainted?
      if dfn.invuln > 0
        emit(:text, dfn, "desviou!")
        return
      end
      eff = spec.effect || {}
      if spec.power.to_i > 0 || eff[:fixed]
        mult = @type_mult.call(spec.type, dfn.types)
        if mult == 0
          emit(:text, dfn, "não afeta")
          return
        end
        hits = eff[:hits] || 1
        crit = rand_f < [1.0 / 24, 1.0 / 8, 0.5, 1.0][att.stages[:crit].clamp(0, 3)]
        total = 0
        hits.times { total += calc_damage(att, dfn, spec, mult, crit) }
        apply_damage(dfn, total, att, mult, crit)
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
      apply_target_effect(att, dfn, spec) unless dfn.fainted?
      apply_self_effect(att, spec) if spec.kind != :buff && eff[:user_stages] && spec.power.to_i > 0
    end

    def calc_damage(att, dfn, spec, mult, crit)
      eff = spec.effect || {}
      if eff[:fixed]
        return eff[:fixed] == :level ? att.level : eff[:fixed]
      end
      physical = (spec.category == 0)
      a = physical ? att.stat(:atk) : att.stat(:spa)
      d = physical ? dfn.stat(:def) : dfn.stat(:spd)
      d = 1.0 if d < 1
      base = (((2.0 * att.level / 5 + 2) * spec.power * a / d) / 50.0) + 2
      base *= 1.5 if att.types.map(&:to_s).include?(spec.type.to_s)
      base *= mult
      base *= 1.5 if crit
      base *= 0.5 if physical && att.status == :BURN
      base *= (85 + @rng.rand(16)) / 100.0
      base *= RTB.damage_scale
      [base.floor, 1].max
    end

    def apply_damage(f, dmg, by, mult, crit)
      return if f.fainted?
      dmg = f.hp if dmg > f.hp
      f.pkmn.hp -= dmg
      f.flash = 0.2
      f.stun = 0 if f.status == :SLEEP && by   # dano direto acorda
      emit(:damage, f, dmg, mult, crit)
      if f.fainted?
        f.pkmn.hp = 0
        f.pkmn.status = :NONE if f.pkmn.respond_to?(:status=)
        f.lock = 0; f.pending = nil; f.dash = nil
        emit(:faint, f)
      end
    end

    def heal(f, amount)
      return if f.fainted? || amount <= 0
      amount = f.totalhp - f.hp if f.hp + amount > f.totalhp
      f.pkmn.hp += amount
      emit(:heal, f, amount)
    end

    def apply_target_effect(att, dfn, spec)
      eff = spec.effect || {}
      chance = eff[:chance] || 100
      return if rand_f * 100 >= chance
      if eff[:status]
        set_status(dfn, eff[:status], spec)
      end
      if eff[:leech]
        if dfn.types.map(&:to_s).include?("GRASS")
          emit(:text, dfn, "não afeta")
        else
          dfn.leech_by = att.side
          emit(:text, dfn, "foi semeado!")
        end
      end
      emit(:force_out, dfn) if eff[:force_out]
      if eff[:target_stages]
        eff[:target_stages].each do |k, v|
          dfn.stages[k] = (dfn.stages[k] + v).clamp(-6, 6)
        end
        emit(:stages, dfn, eff[:target_stages])
      end
    end

    def apply_self_effect(f, spec)
      eff = spec.effect || {}
      if eff[:user_stages]
        eff[:user_stages].each { |k, v| f.stages[k] = (f.stages[k] + v).clamp(-6, 6) }
        emit(:stages, f, eff[:user_stages])
      end
      heal(f, (f.totalhp * eff[:heal]).floor) if eff[:heal]
      if eff[:rest]
        f.pkmn.status = :SLEEP
        f.stun = 3.0
        emit(:status, f, :SLEEP)
      end
      if eff[:protect]
        f.invuln = [f.invuln, eff[:protect]].max
        emit(:text, f, "se protegeu!")
      end
      if eff[:haze]
        @fighters.each { |x| x.stages.clear }
        emit(:text, f, "atributos de todos voltaram ao normal")
      end
      emit(:flee, f) if eff[:flee]
    end

    IMMUNE = {
      BURN: ["FIRE"], FROZEN: ["ICE"], PARALYSIS: ["ELECTRIC"],
      POISON: ["POISON", "STEEL"]
    }

    def set_status(f, status, spec)
      if status == :CONFUSED
        f.confuse = 4.0
        emit(:status, f, :CONFUSED)
        return
      end
      return if f.status != :NONE && !f.status.nil?
      return if (IMMUNE[status] || []).any? { |t| f.types.map(&:to_s).include?(t) }
      return if status == :PARALYSIS && spec.type.to_s == "ELECTRIC" && f.types.map(&:to_s).include?("GROUND")
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
        sx = p.vx * dt; sy = p.vy * dt
        p.x += sx; p.y += sy
        p.dist += Math.sqrt(sx * sx + sy * sy)
        if p.dist >= p.max || !inside_arena?(p.x, p.y) || !@walkable.call(p.x, p.y)
          p.dead = true
          add_effect(:puff, p.x, p.y, r: p.r + 4, max: 0.15, type: p.spec.type)
          next
        end
        @fighters.each do |f|
          next if f.side == p.owner.side || f.fainted? || f.hidden
          next if Math.hypot(f.x - p.x, f.y - p.y) > f.radius + p.r
          p.dead = true
          add_effect(:puff, p.x, p.y, r: p.r + 8, max: 0.2, type: p.spec.type)
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
               when :projectile, :status then 150
               when :beam then 190
               else 120
               end
      mx = 0.0; my = 0.0
      if d > want_d + 18
        mx, my = ux, uy
      elsif d < want_d - 25
        mx, my = -ux, -uy
      else
        mx, my = -uy * ai[:strafe] * 0.7, ux * ai[:strafe] * 0.7
      end
      input = { mx: mx, my: my, face: [ux, uy] }
      # Desvia de projéteis que vêm na direção dele
      dodge_chance = [0.12, 0.3, 0.55][@ai_level] || 0.12
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
        score =
          if spec.power.to_i > 0
            spec.power * @type_mult.call(spec.type, foe.types) *
              (f.types.map(&:to_s).include?(spec.type.to_s) ? 1.5 : 1.0)
          elsif spec.kind == :status
            (foe.status == :NONE || foe.status.nil?) ? 35 : 0
          elsif spec.kind == :buff || spec.kind == :debuff
            20
          else
            0
          end
        score *= 0.6 + rand_f * 0.8
        next if score <= 0
        if score > best_score
          best = i; best_score = score
        end
      end
      best
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
      f.x += dx if free?(f, f.x + dx, f.y)
      f.y += dy if free?(f, f.x, f.y + dy)
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

    def add_effect(kind, x, y, r: 0, max: 0.2, x2: nil, y2: nil, type: nil)
      @effects.push(Effect.new(kind: kind, x: x, y: y, x2: x2, y2: y2, r: r, t: 0.0,
                               max: max, type: type))
    end
  end
end
