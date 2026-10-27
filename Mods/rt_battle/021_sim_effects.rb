#==============================================================================
# Batalha em tempo real — efeitos dos golpes (Ruby puro, sem RGSS)
#
# Clima, terrenos, telas, armadilhas no chão, substituto, golpes que chamam
# outros golpes, golpes de dois turnos, poder variável etc. Cada efeito do jogo
# por turno vira uma versão com duração em segundos. As chaves de efeito vêm da
# tabela EFFECTS (010_moves.rb); a lista completa está em
# docs/B2-golpes-tempo-real.md.
#==============================================================================
module RTB
  WEATHER_TIME = 20.0
  TERRAIN_TIME = 20.0
  HAZARD_TIME  = 40.0
  FIELD_TICK   = 1.5   # dano/cura de clima, terreno, Wrap... a cada 1,5 s

  WEATHER_NAMES = { RAIN: "Chuva", SUN: "Sol forte", SAND: "Tempestade de areia", HAIL: "Granizo" }
  TERRAIN_NAMES = { ELECTRIC: "Campo elétrico", GRASSY: "Campo de grama", MISTY: "Campo de névoa",
                    PSYCHIC: "Campo psíquico" }
  HAZARD_NAMES  = { spikes: "Spikes", toxic_spikes: "Toxic Spikes", stealth_rock: "Stealth Rock",
                    sticky_web: "Sticky Web" }
  HAZARD_TYPES  = { spikes: :GROUND, toxic_spikes: :POISON, stealth_rock: :ROCK, sticky_web: :BUG }

  class Sim
    SEMI_TEXT = { fly: "voou alto!", dig: "cavou um buraco!", dive: "mergulhou!", phantom: "sumiu!" }

    # Golpes que o jogo marca com a flag "k" (som) passam pelo substituto.
    def sound?(spec)
      spec.kind == :pulse && spec.power.to_i > 0 && !spec.contact
    end

    #--------------------------------------------------------------------------
    # Entrada em campo: Healing Wish, armadilhas já no chão
    #--------------------------------------------------------------------------
    def on_enter(f)
      # Mean Look e afins valem só enquanto quem prendeu está em campo
      @fighters.each { |x| x.timers[:trapped] = 0 if x.side != f.side }
      fx = @side_fx[f.side]
      if fx[:healing_wish] > 0
        fx[:healing_wish] = 0
        f.pkmn.hp = f.totalhp
        f.pkmn.status = :NONE
        f.stun = 0
        emit(:text, f, "foi curado pelo desejo!")
      end
    end

    #--------------------------------------------------------------------------
    # Campo: clima, terreno, telas, armadilhas
    #--------------------------------------------------------------------------
    def step_field(dt)
      if @weather
        @weather_t -= dt
        if @weather_t <= 0
          emit(:text, nil, "#{WEATHER_NAMES[@weather]} acabou")
          @weather = nil
        end
      end
      if @terrain
        @terrain_t -= dt
        if @terrain_t <= 0
          emit(:text, nil, "#{TERRAIN_NAMES[@terrain]} acabou")
          @terrain = nil
        end
      end
      @side_fx.each { |h| h.each_key { |k| h[k] -= dt if h[k] > 0 } }
      @field.each_key { |k| @field[k] -= dt if @field[k] > 0 }
      step_hazards(dt)
      @field_tick += dt
      return if @field_tick < FIELD_TICK
      @field_tick -= FIELD_TICK
      @fighters.each do |f|
        next if f.fainted? || f.hidden
        weather_chip(f)
        if @terrain == :GRASSY && f.grounded?(gravity?) && f.hp < f.totalhp
          heal(f, [f.totalhp / 16, 1].max)
        end
      end
    end

    def gravity?
      @field[:gravity] > 0
    end

    def weather_chip(f)
      case @weather
      when :SAND
        return if %w[ROCK GROUND STEEL].any? { |t| f.type?(t) }
        emit(:text, f, "a areia machuca")
        apply_damage(f, [f.totalhp / 16, 1].max, nil, 1.0, false)
      when :HAIL
        return if f.type?(:ICE)
        emit(:text, f, "o granizo machuca")
        apply_damage(f, [f.totalhp / 16, 1].max, nil, 1.0, false)
      end
    end

    def step_hazards(dt)
      @hazards.each { |h| h.t -= dt }
      @hazards.reject! { |h| h.t <= 0 }
      @fighters.each do |f|
        next if f.fainted? || f.hidden || f.semi
        @hazards.each do |h|
          next if h.side == f.side || h.t <= 0
          next if Math.hypot(f.x - h.x, f.y - h.y) > h.r + f.radius * 0.6
          next unless h.kind == :stealth_rock || f.grounded?(gravity?)
          touch_hazard(f, h)
        end
      end
      @hazards.reject! { |h| h.t <= 0 }
    end

    def touch_hazard(f, h)
      case h.kind
      when :spikes
        h.t = 0
        apply_damage(f, [f.totalhp / 8, 1].max, nil, 1.0, false)
        emit(:text, f, "pisou nos espinhos!")
      when :toxic_spikes
        h.t = 0
        if f.type?(:POISON)
          emit(:text, f, "recolheu os espinhos tóxicos")
        else
          set_status(f, :POISON, nil)
        end
      when :stealth_rock
        h.t = 0
        mult = @type_mult.call(:ROCK, f.types)
        apply_damage(f, [(f.totalhp * mult / 8.0).floor, 1].max, nil, mult, false)
        emit(:text, f, "pedras pontudas o acertaram!")
      when :sticky_web
        return if f.timers[:web] > 0
        f.timers[:web] = 2.0
        apply_stages(f, { spe: -1 }, nil)
        emit(:text, f, "ficou preso na teia!")
      end
    end

    # Spikes: três pontas em volta do ponto; Toxic Spikes e Stealth Rock: duas; Sticky Web: uma teia larga.
    def lay_hazard(f, spec, px, py)
      kind = spec.effect[:hazard]
      mine = @hazards.select { |h| h.side == f.side && h.kind == kind }
      if mine.length >= 6
        emit(:text, f, "Mas falhou!")
        return
      end
      offsets =
        case kind
        when :spikes then [[0, 0], [-22, 16], [22, 16]]
        when :sticky_web then [[0, 0]]
        else [[-14, 0], [14, 0]]
        end
      r = kind == :sticky_web ? 34 : 12
      offsets.each do |ox, oy|
        x = (px + ox).clamp(@arena[0] + 8, @arena[2] - 8)
        y = (py + oy).clamp(@arena[1] + 8, @arena[3] - 8)
        @hazards.push(Hazard.new(kind: kind, side: f.side, x: x, y: y, r: r, t: HAZARD_TIME,
                                 type: HAZARD_TYPES[kind]))
      end
      add_effect(:puff, px, py, r: spec.width, max: 0.25, type: spec.type, spec: spec)
      emit(:anim, f, spec, f.x, f.y, px, py, :full)
      emit(:text, f, "espalhou #{HAZARD_NAMES[kind]}!")
    end

    #--------------------------------------------------------------------------
    # Efeitos com duração em cada Pokémon
    #--------------------------------------------------------------------------
    def tick_effects(f, dt)
      wish = f.timers[:wish]
      f.timers.each_key { |k| f.timers[k] -= dt if f.timers[k] > 0 }
      f.sub_hp = 0 if f.sub_hp < 0
      if f.timers[:bound] > 0 || f.timers[:nightmare] > 0 || f.timers[:ingrain] > 0
        f.bind_t += dt
        if f.bind_t >= FIELD_TICK
          f.bind_t -= FIELD_TICK
          if f.timers[:bound] > 0
            apply_damage(f, [f.totalhp / 8, 1].max, nil, 1.0, false)
          end
          if f.timers[:nightmare] > 0
            if f.status == :SLEEP
              emit(:text, f, "está tendo um pesadelo")
              apply_damage(f, [f.totalhp / 4, 1].max, nil, 1.0, false)
            else
              f.timers[:nightmare] = 0
            end
          end
          heal(f, [f.totalhp / 16, 1].max) if f.timers[:ingrain] > 0 && f.hp < f.totalhp
        end
      end
      if wish > 0 && f.timers[:wish] <= 0
        heal(f, (f.totalhp / 2.0).floor)
        emit(:text, f, "o desejo se realizou")
      end
      if f.perish
        before = f.perish.ceil
        f.perish -= dt
        if f.perish <= 0
          f.perish = nil
          emit(:text, f, "a canção acabou")
          apply_damage(f, f.hp, nil, 1.0, false)
        elsif f.perish.ceil != before && f.perish.ceil % 3 == 0
          emit(:text, f, "contagem: #{f.perish.ceil / 3}")
        end
      end
    end

    def sleep_usable?(f, slot)
      spec = f.specs[slot]
      return false unless spec && f.can_use_asleep?(slot)
      eff = spec.effect || {}
      eff[:sleep_usable] || eff[:call] == :sleep_talk
    end

    def can_dodge?(f)
      f.timers[:bound] <= 0 && f.timers[:telekinesis] <= 0 && !gravity?
    end

    def move_speed_of(f)
      sp = f.move_speed
      sp *= 1.4 if @side_fx[f.side][:tailwind] > 0
      sp = (290.0 - sp).clamp(90.0, 200.0) if @field[:trick_room] > 0
      sp
    end

    # Pode escapar (fugir/trocar)? Mean Look, Wrap e Ingrain prendem.
    def can_escape?(f)
      f.timers[:trapped] <= 0 && f.timers[:bound] <= 0 && f.timers[:ingrain] <= 0
    end

    # Jump Kick e afins: errar machuca quem usou.
    def crash(f, spec)
      frac = (spec.effect || {})[:crash]
      return unless frac && !f.fainted?
      emit(:text, f, "caiu no chão!")
      apply_damage(f, [(f.totalhp * frac).floor, 1].max, nil, 1.0, false)
    end

    #--------------------------------------------------------------------------
    # Antes e depois de usar um golpe
    #--------------------------------------------------------------------------
    def move_allowed?(f, spec, slot)
      eff = spec.effect || {}
      foe = opponent(f)
      fail = nil
      if f.timers[:infatuated] > 0 && rand_f < 0.5
        emit(:text, f, "está apaixonado!")
        return false
      end
      fail = true if eff[:first_only] && f.age > 2.5
      fail = true if eff[:sucker_punch] && !(foe && foe.pending && foe.pending[0].power.to_i > 0)
      fail = true if eff[:needs_sleep] && !(foe && foe.status == :SLEEP)
      fail = true if eff[:hp_cost] && spec.power.to_i == 0 && f.hp <= (f.totalhp * eff[:hp_cost]).floor
      fail = true if eff[:belly_drum] && f.hp <= f.totalhp / 2
      fail = true if eff[:substitute] && (f.sub_hp > 0 || f.hp <= f.totalhp / 4)
      fail = true if eff[:burn_up] && !f.type?(:FIRE)
      if f.timers[:taunt] > 0 && spec.power.to_i == 0
        emit(:text, f, "foi provocado e não pode usar isso!")
        return false
      end
      if fail
        emit(:text, f, "Mas falhou!")
        return false
      end
      if f.timers[:torment] > 0
        f.cds[slot] = [f.cds[slot], 2.5].max
      end
      true
    end

    def windup_of(f, spec)
      eff = spec.effect || {}
      w = spec.windup
      w -= eff[:charge] if eff[:solar] && @weather == :SUN
      w
    end

    def remember_use(f, spec)
      return if (spec.effect || {})[:call]
      f.last_spec = spec
      @last_spec = spec
    end

    # Golpes que custam vida ou derrubam quem usa (Explosion, Memento, Healing Wish).
    # Devolve true quando o golpe acaba aqui.
    def before_release(f, spec, foe)
      eff = spec.effect || {}
      if eff[:hp_cost]
        apply_damage(f, [(f.totalhp * eff[:hp_cost]).floor, 1].max, nil, 1.0, false)
      end
      if eff[:self_faint] && spec.power.to_i == 0
        # Memento: efeito imediato no alvo, sem disparo
        if foe && dist(f, foe) <= spec.range + foe.radius
          emit(:anim, f, spec, f.x, f.y, foe.x, foe.y, :full)
          apply_target_effect(f, foe, spec)
        end
        apply_damage(f, f.hp, nil, 1.0, false)
        return true
      end
      false
    end

    def after_release(f, spec, foe)
      eff = spec.effect || {}
      if eff[:self_faint] && spec.power.to_i > 0 && !f.fainted?
        apply_damage(f, f.hp, nil, 1.0, false)
      end
      if eff[:recharge] && !f.fainted?
        f.stun = [f.stun, eff[:recharge]].max
        emit(:text, f, "precisa recarregar")
      end
      if eff[:rampage] && !f.fainted? && f.confuse <= 0
        f.confuse = 3.0
        emit(:status, f, :CONFUSED)
      end
    end

    # Golpe que chama outro golpe: devolve a spec chamada (ou nil se falhou).
    def resolve_call(f, spec, slot)
      foe = opponent(f)
      called =
        case spec.effect[:call]
        when :mirror_move, :me_first then foe && foe.last_spec
        when :copycat then @last_spec
        when :metronome then @random_spec && @random_spec.call(f.side)
        when :nature_power then @spec_lookup && @spec_lookup.call(nature_power_move, f.side)
        when :sleep_talk
          return nil unless f.status == :SLEEP
          own_other_spec(f, slot)
        when :assist then own_other_spec(f, slot)
        end
      return nil unless called
      return nil if (called.effect || {})[:call]
      emit(:text, f, "usou #{called.name}!")
      called
    end

    def nature_power_move
      { ELECTRIC: :THUNDERBOLT, GRASSY: :ENERGYBALL, MISTY: :MOONBLAST, PSYCHIC: :PSYCHIC }[@terrain] || :TRIATTACK
    end

    def own_other_spec(f, slot)
      list = f.specs.each_with_index.reject do |s, i|
        i == slot || (s.effect || {})[:call] || (s.effect || {})[:charge] || (s.effect || {})[:semi]
      end
      return nil if list.empty?
      list[@rng.rand(list.length)][0]
    end

    #--------------------------------------------------------------------------
    # Acerto
    #--------------------------------------------------------------------------
    # Protect, esquiva, Fly/Dig, Magic Coat e golpes que só funcionam em certas condições.
    def hit_allowed?(att, dfn, spec)
      eff = spec.effect || {}
      if dfn.semi && !(eff[:hits_semi] || []).include?(dfn.semi)
        emit(:text, dfn, "não foi alcançado")
        return false
      end
      if dfn.invuln > 0
        if dfn.timers[:protect] > 0 && eff[:pierce_protect]
          dfn.invuln = 0; dfn.timers[:protect] = 0
          emit(:text, dfn, "a proteção quebrou!")
        else
          protect_retaliate(att, dfn, spec) if dfn.timers[:protect] > 0
          emit(:text, dfn, dfn.timers[:protect] > 0 ? "se protegeu!" : "desviou!")
          return false
        end
      end
      if eff[:synchronoise] && (att.types.map(&:to_s) & dfn.types.map(&:to_s)).empty?
        emit(:text, dfn, "não afeta")
        return false
      end
      if spec.power.to_i == 0 && dfn.timers[:magic_coat] > 0 && att != dfn
        dfn.timers[:magic_coat] = 0
        emit(:text, dfn, "refletiu o golpe!")
        apply_target_effect(dfn, att, spec)
        return false
      end
      true
    end

    def protect_retaliate(att, dfn, spec)
      return unless spec.contact
      case dfn.protect_kind
      when :spiky
        apply_damage(att, [att.totalhp / 8, 1].max, nil, 1.0, false)
        emit(:text, att, "se espetou!")
      when :kings_shield then apply_stages(att, { atk: -1 }, dfn)
      when :obstruct then apply_stages(att, { def: -2 }, dfn)
      when :baneful then set_status(att, :POISON, nil)
      end
    end

    def type_mult_for(att, dfn, spec)
      eff = spec.effect || {}
      types = dfn.types.map(&:to_s)
      if dfn.timers[:identified] > 0
        types -= ["GHOST"] if %w[NORMAL FIGHTING].include?(spec.type.to_s) && dfn.timers[:identify_type] == 1
        types -= ["DARK"] if spec.type.to_s == "PSYCHIC" && dfn.timers[:identify_type] == 2
      end
      types -= ["FLYING"] if spec.type.to_s == "GROUND" && (gravity? || eff[:hits_semi])
      types = ["NORMAL"] if types.empty?
      return 0.0 if spec.type.to_s == "GROUND" && spec.power.to_i > 0 && !dfn.grounded?(gravity?) &&
                    !dfn.type?(:FLYING)
      mult = @type_mult.call(spec.type, types.map(&:to_sym))
      mult *= 4.0 if eff[:freeze_dry] && dfn.type?(:WATER)
      mult = 1.0 if eff[:fixed] && mult > 0
      mult
    end

    def crit_roll(att, dfn, spec)
      return false if @side_fx[dfn.side][:lucky_chant] > 0
      return true if (spec.effect || {})[:always_crit]
      rand_f < [1.0 / 24, 1.0 / 8, 0.5, 1.0][att.stages[:crit].clamp(0, 3)]
    end

    # Dano que não segue a fórmula: Counter, OHKO.
    def special_damage(att, dfn, spec, total)
      eff = spec.effect || {}
      if eff[:counter]
        window = eff[:counter] == :bide ? 3.0 : 2.0
        taken = att.recent.select do |t, _, cat, side|
          @time - t <= window && side == dfn.side &&
            (eff[:counter].is_a?(Symbol) || cat == eff[:counter])
        end.sum { |r| r[1] }
        if taken <= 0
          emit(:text, att, "Mas falhou!")
          return nil
        end
        return (taken * (eff[:counter] == :any ? 1.5 : 2.0)).floor
      end
      if eff[:ohko]
        if att.level < dfn.level
          emit(:text, dfn, "não afeta")
          return nil
        end
        emit(:text, dfn, "nocaute num golpe!")
        return dfn.hp
      end
      total
    end

    def absorb_substitute(dfn, total, spec)
      return total if dfn.sub_hp <= 0 || sound?(spec)
      dfn.sub_hp -= total
      if dfn.sub_hp <= 0
        dfn.sub_hp = 0
        emit(:text, dfn, "o substituto sumiu!")
      else
        emit(:text, dfn, "o substituto aguentou")
      end
      0
    end

    def fixed_damage(att, dfn, kind)
      case kind
      when :level then att.level
      when :half_target then [dfn.hp / 2, 1].max
      when :endeavor then [dfn.hp - att.hp, 0].max
      when :psywave then [(att.level * (0.5 + rand_f)).floor, 1].max
      when :final_gambit then att.hp
      else kind
      end
    end

    def attack_defense(att, dfn, spec, physical, crit)
      eff = spec.effect || {}
      a = physical ? att.stat(:atk) : att.stat(:spa)
      a = dfn.stat(:atk) if eff[:foul_play]
      a = att.stat(:def) if eff[:body_press]
      dkey = physical || eff[:use_def] ? :def : :spd
      dkey = (dkey == :def ? :spd : :def) if @field[:wonder_room] > 0
      d = dfn.stat(dkey)
      if eff[:ignore_def_stages] || (crit && dfn.stages[dkey] > 0)
        d = dfn.stat(dkey) / RTB.stage_mult(dfn.stages[dkey])
      end
      [a, d]
    end

    # Poder do golpe na hora (Flail, Gyro Ball, Hex...).
    def power_for(att, dfn, spec)
      eff = spec.effect || {}
      p = spec.power.to_f
      p *= 2 if dfn.semi && (eff[:hits_semi] || []).include?(dfn.semi)
      case eff[:power_fn]
      when :venoshock then p *= 2 if dfn.status == :POISON
      when :hex then p *= 2 if dfn.status && dfn.status != :NONE
      when :brine then p *= 2 if dfn.hp * 2 <= dfn.totalhp
      when :facade then p *= 2 if [:BURN, :POISON, :PARALYSIS].include?(att.status)
      when :smelling_salts then p *= 2 if dfn.status == :PARALYSIS
      when :wake_up_slap then p *= 2 if dfn.status == :SLEEP
      when :revenge then p *= 2 if att.recent.any? { |t, _, _, s| @time - t <= 1.5 && s == dfn.side }
      when :assurance then p *= 2 if dfn.recent.any? { |t, _, _, _| @time - t <= 1.5 }
      when :acrobatics then p *= 2
      when :weather_ball then p *= 2 if @weather
      when :return then p = 102
      when :frustration then p = 102
      when :eruption then p = [150.0 * att.hp / att.totalhp, 1].max
      when :wring_out then p = [120.0 * dfn.hp / dfn.totalhp, 1].max
      when :flail
        r = 48.0 * att.hp / att.totalhp
        p = r < 2 ? 200 : r < 5 ? 150 : r < 10 ? 100 : r < 17 ? 80 : r < 33 ? 40 : 20
      when :gyro_ball then p = [[25.0 * dfn.stat(:spe) / [att.stat(:spe), 1].max, 1].max, 150].min
      when :electro_ball
        r = att.stat(:spe) / [dfn.stat(:spe), 1].max
        p = r >= 4 ? 150 : r >= 3 ? 120 : r >= 2 ? 80 : r >= 1 ? 60 : 40
      when :stored_power then p = 20 + 20 * att.stages.values.select(&:positive?).sum
      when :punishment then p = [60 + 20 * dfn.stages.values.select(&:positive?).sum, 200].min
      when :magnitude then p = [10, 30, 50, 70, 90, 110, 150][@rng.rand(7)]
      when :present then p = [40, 80, 120][@rng.rand(3)]
      when :trump_card then p = 80
      when :low_kick then p = weight_power(weight_of(dfn))
      when :heavy_slam
        r = weight_of(att) / [weight_of(dfn), 0.1].max
        p = r >= 5 ? 120 : r >= 4 ? 100 : r >= 3 ? 80 : r >= 2 ? 60 : 40
      when :fury_cutter
        n, last = att.combo[spec.id] || [0, -99]
        n = @time - last <= 3.0 ? n + 1 : 1
        att.combo[spec.id] = [n, @time]
        p = [p * 2**(n - 1), spec.power.to_f * 16].min
      end
      p *= 0.5 if eff[:solar] && @weather && @weather != :SUN
      p
    end

    def weight_of(f)
      w = f.pkmn.species_data.weight rescue nil
      w ? w / 10.0 : 30.0
    end

    def weight_power(kg)
      kg >= 200 ? 120 : kg >= 100 ? 100 : kg >= 50 ? 80 : kg >= 25 ? 60 : kg >= 10 ? 40 : 20
    end

    # Clima, terreno, telas e Mud/Water Sport.
    def field_mult(att, dfn, spec, physical, crit)
      t = spec.type.to_s
      m = 1.0
      case @weather
      when :RAIN then m *= 1.5 if t == "WATER"; m *= 0.5 if t == "FIRE"
      when :SUN  then m *= 1.5 if t == "FIRE";  m *= 0.5 if t == "WATER"
      end
      if att.grounded?(gravity?)
        m *= 1.3 if (@terrain == :ELECTRIC && t == "ELECTRIC") || (@terrain == :GRASSY && t == "GRASS") ||
                    (@terrain == :PSYCHIC && t == "PSYCHIC")
      end
      m *= 0.5 if @terrain == :MISTY && t == "DRAGON" && dfn.grounded?(gravity?)
      m *= 0.33 if @field[:mud_sport] > 0 && t == "ELECTRIC"
      m *= 0.33 if @field[:water_sport] > 0 && t == "FIRE"
      fx = @side_fx[dfn.side]
      unless crit
        m *= 0.5 if physical && fx[:reflect] > 0
        m *= 0.5 if !physical && fx[:light_screen] > 0
      end
      m
    end

    def after_hit(att, dfn, spec)
      eff = spec.effect || {}
      @side_fx[dfn.side][:reflect] = @side_fx[dfn.side][:light_screen] = 0 if eff[:break_screens]
      if dfn.fainted?
        apply_stages(att, { atk: 3 }, att) if eff[:fell_stinger]
        return
      end
      if eff[:power_fn] == :wake_up_slap && dfn.status == :SLEEP
        dfn.pkmn.status = :NONE; dfn.stun = 0
        emit(:text, dfn, "acordou")
      end
      if eff[:power_fn] == :smelling_salts && dfn.status == :PARALYSIS
        dfn.pkmn.status = :NONE
        emit(:text, dfn, "curou a paralisia")
      end
      if eff[:bind] && dfn.timers[:bound] <= 0
        dfn.timers[:bound] = eff[:bind]
        dfn.lock = 0; dfn.pending = nil
        emit(:text, dfn, "ficou preso!")
      end
      knockback(att, dfn, eff[:knockback]) if eff[:knockback]
      if eff[:rapid_spin]
        @hazards.reject! { |h| h.side != att.side }
        att.leech_by = nil; att.timers[:bound] = 0
      end
      if eff[:burn_up]
        att.type_override = att.types.reject { |t| t.to_s == "FIRE" }
        att.type_override = [:NORMAL] if att.type_override.empty?
      end
      emit(:switch_out, att, nil) if eff[:switch_out] && spec.power.to_i > 0
    end

    def knockback(att, dfn, d)
      nx, ny = norm(dfn.x - att.x, dfn.y - att.y)
      8.times { move_by(dfn, nx * d / 8.0, ny * d / 8.0) }
      dfn.lock = 0; dfn.pending = nil
      emit(:text, dfn, "foi arremessado!")
    end

    # Recuo (flinch): interrompe o golpe que o alvo estava preparando.
    def flinch(f)
      return if f.fainted? || f.status == :SLEEP
      f.lock = 0; f.pending = nil; f.semi = nil
      f.stun = [f.stun, 0.35].max
      emit(:text, f, "recuou!")
    end

    def on_faint(f, by)
      if by && f.timers[:destiny_bond] > 0 && !by.fainted?
        emit(:text, by, "foi levado junto!")
        apply_damage(by, by.hp, nil, 1.0, false)
      end
      if by && f.timers[:grudge] > 0 && by.last_slot && by.pkmn.moves[by.last_slot]
        by.pkmn.moves[by.last_slot].pp = 0
        emit(:text, by, "perdeu todo o PP do golpe!")
      end
    end

    def status_allowed?(f, status)
      return true if status.nil?
      if @side_fx[f.side][:safeguard] > 0
        emit(:text, f, "está protegido")
        return false
      end
      if @terrain == :MISTY && f.grounded?(gravity?)
        emit(:text, f, "a névoa protegeu")
        return false
      end
      return false if status == :SLEEP && ((@terrain == :ELECTRIC && f.grounded?(gravity?)) ||
                                            f.timers[:insomnia] > 0)
      true
    end

    def heal_frac(eff)
      return eff[:heal] unless eff[:weather_heal]
      case @weather
      when nil then 0.5
      when :SUN then 0.66
      else 0.25
      end
    end

    #--------------------------------------------------------------------------
    # Efeitos no alvo
    #--------------------------------------------------------------------------
    def more_target_effects(att, dfn, spec)
      eff = spec.effect || {}
      last = dfn.last_slot
      if eff[:disable]
        if last
          dfn.cds[last] = [dfn.cds[last], eff[:disable]].max
          emit(:text, dfn, "teve #{dfn.specs[last].name} bloqueado")
        else
          emit(:text, dfn, "Mas falhou!")
        end
      end
      if eff[:encore] && last
        dfn.cds.each_index { |i| dfn.cds[i] = [dfn.cds[i], eff[:encore]].max if i != last }
        emit(:text, dfn, "só pode repetir #{dfn.specs[last].name}")
      end
      if eff[:taunt]
        dfn.timers[:taunt] = eff[:taunt]
        emit(:text, dfn, "foi provocado!")
      end
      if eff[:torment]
        dfn.timers[:torment] = eff[:torment]
        emit(:text, dfn, "foi atormentado!")
      end
      if eff[:spite] && last && dfn.pkmn.moves[last]
        mv = dfn.pkmn.moves[last]
        mv.pp = [mv.pp - eff[:spite], 0].max
        emit(:text, dfn, "perdeu PP")
      end
      if eff[:identify]
        dfn.timers[:identified] = 30.0
        dfn.timers[:identify_type] = eff[:identify] == :GHOST ? 1 : 2
        emit(:text, dfn, "foi identificado!")
      end
      if eff[:attract]
        if att.gender < 2 && dfn.gender < 2 && att.gender != dfn.gender
          dfn.timers[:infatuated] = 6.0
          emit(:text, dfn, "se apaixonou!")
        else
          emit(:text, dfn, "não afeta")
        end
      end
      if eff[:pain_split]
        avg = (att.hp + dfn.hp) / 2
        att.pkmn.hp = [avg, att.totalhp].min; dfn.pkmn.hp = [avg, dfn.totalhp].min
        emit(:text, att, "dividiu a dor")
      end
      if eff[:swap]
        eff[:swap].each { |k| att.stages[k], dfn.stages[k] = dfn.stages[k], att.stages[k] }
        emit(:text, att, "trocou atributos")
      end
      if eff[:split]
        eff[:split].each do |k|
          avg = ((att.stages[k] + dfn.stages[k]) / 2.0).round
          att.stages[k] = dfn.stages[k] = avg
        end
        emit(:text, att, "dividiu atributos")
      end
      if eff[:type_target]
        dfn.type_override = eff[:add_type] ? (dfn.types + eff[:type_target]).uniq : eff[:type_target].dup
        emit(:text, dfn, "virou tipo #{eff[:type_target].join('/')}")
      end
      heal(dfn, (dfn.totalhp * eff[:heal_target]).floor) if eff[:heal_target]
      if eff[:nightmare]
        if dfn.status == :SLEEP
          dfn.timers[:nightmare] = 10.0
          emit(:text, dfn, "começou a ter pesadelos")
        else
          emit(:text, dfn, "Mas falhou!")
        end
      end
      if eff[:telekinesis]
        dfn.timers[:telekinesis] = eff[:telekinesis]
        emit(:text, dfn, "foi erguido no ar!")
      end
      if eff[:heal_block]
        dfn.timers[:heal_block] = eff[:heal_block]
        emit(:text, dfn, "não pode mais se curar")
      end
      if eff[:trap]
        dfn.timers[:trapped] = 999.0
        emit(:text, dfn, "não pode mais fugir!")
      end
      if eff[:clear_target]
        dfn.stages.clear
        emit(:text, dfn, "atributos voltaram ao normal")
      end
      if eff[:cure_target] && dfn.status && dfn.status != :NONE
        dfn.pkmn.status = :NONE; dfn.stun = 0
        emit(:text, dfn, "foi curado")
      end
      if eff[:strength_sap]
        heal(att, dfn.stat(:atk).floor)
        apply_stages(dfn, { atk: -1 }, att)
      end
      if eff[:topsy]
        dfn.stages.each_key { |k| dfn.stages[k] = -dfn.stages[k] }
        emit(:text, dfn, "atributos invertidos")
      end
      if eff[:spectral_thief]
        gained = dfn.stages.select { |_, v| v > 0 }
        gained.each { |k, v| att.stages[k] = (att.stages[k] + v).clamp(-6, 6); dfn.stages[k] = 0 }
        emit(:stages, att, gained) unless gained.empty?
      end
      if eff[:insomnia]
        dfn.timers[:insomnia] = 20.0
        if dfn.status == :SLEEP
          dfn.pkmn.status = :NONE; dfn.stun = 0
        end
        emit(:text, dfn, "não consegue mais dormir")
      end
      if eff[:psycho_shift]
        st = att.status
        if st && st != :NONE && (dfn.status.nil? || dfn.status == :NONE)
          att.pkmn.status = :NONE
          set_status(dfn, st, spec)
        else
          emit(:text, att, "Mas falhou!")
        end
      end
      if eff[:mimic]
        if dfn.last_spec && att.last_slot
          att.specs = att.specs.dup
          att.specs[att.specs.index(spec) || att.last_slot] = dfn.last_spec
          emit(:text, att, "copiou #{dfn.last_spec.name}!")
        else
          emit(:text, att, "Mas falhou!")
        end
      end
    end

    #--------------------------------------------------------------------------
    # Efeitos em quem usa e no campo
    #--------------------------------------------------------------------------
    def more_self_effects(f, spec)
      eff = spec.effect || {}
      foe = opponent(f)
      if eff[:weather]
        @weather = eff[:weather]; @weather_t = WEATHER_TIME
        emit(:text, f, "#{WEATHER_NAMES[@weather]}!")
      end
      if eff[:terrain]
        @terrain = eff[:terrain]; @terrain_t = TERRAIN_TIME
        emit(:text, f, "#{TERRAIN_NAMES[@terrain]}!")
      end
      (eff[:side] || {}).each do |k, v|
        @side_fx[f.side][k] = v
        emit(:text, f, SIDE_TEXT[k] || k.to_s)
      end
      (eff[:field] || {}).each do |k, v|
        @field[k] = v
        emit(:text, f, FIELD_TEXT[k] || k.to_s)
      end
      if eff[:cure_self] && f.status && f.status != :NONE
        f.pkmn.status = :NONE; f.stun = 0
        emit(:text, f, "curou o status")
      end
      if eff[:substitute]
        cost = f.totalhp / 4
        apply_damage(f, cost, nil, 1.0, false)
        f.sub_hp = cost
        emit(:text, f, "criou um substituto!")
      end
      if eff[:belly_drum]
        apply_damage(f, f.totalhp / 2, nil, 1.0, false)
        f.stages[:atk] = 6
        emit(:stages, f, { atk: 6 })
      end
      if eff[:wish]
        f.timers[:wish] = 2.0
        emit(:text, f, "fez um desejo")
      end
      { ingrain: "fincou raízes", magnet_rise: "flutua com magnetismo", destiny_bond: "quer levar o outro junto",
        grudge: "guarda rancor", endure: "se prepara para aguentar", lock_on: "mirou no alvo",
        magic_coat: "criou um escudo mágico" }.each do |k, text|
        next unless eff[k]
        f.timers[k] = eff[k].is_a?(Numeric) ? eff[k] : (k == :lock_on ? 4.0 : 3.0)
        emit(:text, f, text)
      end
      emit(:text, f, "Mas nada aconteceu!") if eff[:nothing]
      if eff[:perish]
        @fighters.each { |x| x.perish ||= 9.0 unless x.fainted? || x.hidden }
        emit(:text, f, "todos que ouvirem vão desmaiar em 9 s")
      end
      if eff[:healing_wish]
        @side_fx[f.side][:healing_wish] = 999.0
        apply_damage(f, f.hp, nil, 1.0, false)
      end
      emit(:switch_out, f, { stages: f.stages.dup, sub_hp: f.sub_hp }) if eff[:baton_pass]
      if eff[:transform] && foe
        f.specs = foe.specs.first([f.specs.length, 1].max).map(&:dup)
        f.type_override = foe.types.dup
        foe.stages.each { |k, v| f.stages[k] = v }
        emit(:text, f, "se transformou em #{foe.name}!")
      end
      if eff[:type_self]
        t = case eff[:type_self]
            when :first_move then f.specs.first && f.specs.first.type
            when :camouflage then { ELECTRIC: :ELECTRIC, GRASSY: :GRASS, MISTY: :FAIRY, PSYCHIC: :PSYCHIC }[@terrain] || :NORMAL
            when :copy_target then nil
            when :resist_last then foe && foe.last_spec && resisting_type(foe.last_spec.type)
            end
        if eff[:type_self] == :copy_target && foe
          f.type_override = foe.types.dup
          emit(:text, f, "copiou o tipo de #{foe.name}")
        elsif t
          f.type_override = [t.to_sym]
          emit(:text, f, "virou tipo #{t}")
        else
          emit(:text, f, "Mas falhou!")
        end
      end
      if eff[:acupressure]
        k = STAGE_KEYS[@rng.rand(STAGE_KEYS.length)]
        apply_stages(f, { k => 2 }, f)
      end
      if eff[:power_trick]
        f.power_trick = !f.power_trick
        emit(:text, f, "trocou Ataque e Defesa")
      end
      if eff[:defog]
        @hazards.clear
        if foe
          @side_fx[foe.side][:reflect] = @side_fx[foe.side][:light_screen] = 0
          @side_fx[foe.side][:safeguard] = @side_fx[foe.side][:mist] = 0
        end
        emit(:text, f, "o vento limpou o campo")
      end
      if eff[:psych_up] && foe
        STAGE_KEYS.each { |k| f.stages[k] = foe.stages[k] }
        emit(:text, f, "copiou os atributos de #{foe.name}")
      end
      emit(:text, f, "(habilidades ainda não contam no tempo real)") if eff[:no_ability]
      emit(:text, f, "(itens ainda não contam no tempo real)") if eff[:no_item]
      if eff[:imprison] && foe
        mine = f.specs.map(&:id)
        foe.specs.each_with_index { |s, i| foe.cds[i] = [foe.cds[i], 10.0].max if mine.include?(s.id) }
        emit(:text, f, "selou os golpes em comum")
      end
      if eff[:grass_stages]
        @fighters.each { |x| apply_stages(x, eff[:grass_stages], f) if x.type?(:GRASS) && !x.fainted? }
      end
      if eff[:court_change]
        @side_fx[0], @side_fx[1] = @side_fx[1], @side_fx[0]
        @hazards.each { |h| h.side = 1 - h.side }
        emit(:text, f, "trocou os efeitos de lado")
      end
    end

    SIDE_TEXT = { reflect: "Reflect protege contra golpes físicos", light_screen: "Light Screen protege contra golpes especiais",
                  safeguard: "protegido contra status", mist: "a névoa protege os atributos",
                  tailwind: "o vento sopra a favor", lucky_chant: "protegido de golpes críticos" }
    FIELD_TEXT = { mud_sport: "golpes elétricos enfraquecem", water_sport: "golpes de fogo enfraquecem",
                   gravity: "a gravidade aumentou", trick_room: "as dimensões se distorceram",
                   wonder_room: "Defesa e Defesa Especial trocadas" }

    def resisting_type(atk_type)
      %i[STEEL WATER FIRE GRASS ROCK GHOST NORMAL FLYING DRAGON FAIRY].find do |t|
        @type_mult.call(atk_type, [t]) < 1
      end
    end

    #--------------------------------------------------------------------------
    # Projéteis teleguiados (Swift, Aerial Ace... e depois de Lock-On)
    #--------------------------------------------------------------------------
    def steer(p, dt)
      target = active(1 - p.owner.side)
      return unless target
      sp = Math.hypot(p.vx, p.vy)
      return if sp <= 0
      want = Math.atan2(target.y - p.y, target.x - p.x)
      cur = Math.atan2(p.vy, p.vx)
      diff = (want - cur + Math::PI) % (2 * Math::PI) - Math::PI
      turn = 7.0 * dt
      cur += diff.clamp(-turn, turn)
      p.vx = Math.cos(cur) * sp; p.vy = Math.sin(cur) * sp
    end

    #--------------------------------------------------------------------------
    # IA: quanto vale usar cada golpe agora
    #--------------------------------------------------------------------------
    def ai_score(f, foe, spec)
      eff = spec.effect || {}
      hp = f.hp.to_f / [f.totalhp, 1].max
      foe_clean = foe.status.nil? || foe.status == :NONE
      if spec.power.to_i > 0 || eff[:fixed] || eff[:counter] || eff[:ohko]
        return 0 if eff[:needs_sleep] && foe.status != :SLEEP
        return 0 if eff[:first_only] && f.age > 2.5
        return 0 if eff[:sucker_punch] && !(foe.pending && foe.pending[0].power.to_i > 0)
        return 0 if eff[:counter] && f.recent.none? { |t, _, _, s| @time - t <= 1.5 && s == foe.side }
        return 0 if eff[:burn_up] && !f.type?(:FIRE)
        base = (eff[:fixed] || eff[:counter] || eff[:ohko]) ? 60 : spec.power.to_f
        score = base * type_mult_for(f, foe, spec) * (f.type?(spec.type) ? 1.5 : 1.0)
        score *= 0.05 if eff[:self_faint] && hp > 0.3
        score *= 0.8 if eff[:recharge] || eff[:charge]
        return score
      end
      return 0 if eff[:nothing] == :ally || eff[:heal_target]
      return 5 if eff[:nothing]
      return 0 if (eff[:self_faint] || eff[:healing_wish]) && hp > 0.25
      return (foe_clean ? 35 : 0) if eff[:status] && !eff[:target_stages]
      return (1.0 - hp) * 70 if eff[:heal] && !eff[:user_stages]
      return 0 if eff[:weather] && @weather == eff[:weather]
      return 0 if eff[:terrain] && @terrain == eff[:terrain]
      return 0 if eff[:side] && eff[:side].keys.all? { |k| @side_fx[f.side][k] > 0 }
      return 0 if eff[:hazard] && @hazards.count { |h| h.side == f.side } >= 3
      return 0 if eff[:substitute] && (f.sub_hp > 0 || hp < 0.35)
      return 0 if eff[:belly_drum] && hp < 0.6
      return 0 if eff[:perish] && f.perish
      return 0 if eff[:leech] && (foe.leech_by || foe.type?(:GRASS))
      return 12 if eff[:protect]
      return 25 if eff[:weather] || eff[:terrain] || eff[:hazard] || eff[:side]
      return 20 if spec.kind == :buff || spec.kind == :debuff || eff[:target_stages]
      15
    end
  end

  class Fighter
    # Sleep Talk e Snore podem ser usados dormindo (só confere recarga e PP).
    def can_use_asleep?(slot)
      return false if slot >= @specs.length || @cds[slot] > 0 || @lock > 0
      move_pp(slot) > 0
    end
  end
end
