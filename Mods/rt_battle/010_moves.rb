#==============================================================================
# Batalha em tempo real — classificação dos golpes (plano v0.5, seção 7)
#
# Converte os dados de um golpe do Essentials (categoria, alvo, flags, código de
# efeito, poder) numa "spec" de tempo real: família, alcance, preparação,
# recarga e efeito. Ruby puro: não depende do RGSS, para poder ser testado fora
# do jogo. Golpes que precisarem de ajuste à mão entram em OVERRIDES.
#==============================================================================
module RTB
  # Famílias (kind):
  #   :melee      golpe curto à frente
  #   :dash       avanço que acerta quem estiver no caminho
  #   :projectile disparo que viaja em linha reta
  #   :beam       feixe instantâneo e longo, depois de uma preparação
  #   :pulse      área em volta de quem usa
  #   :status     disparo sem dano que aplica um efeito no alvo
  #   :debuff     área sem dano que reduz atributos de quem estiver perto
  #   :strike     cai num ponto marcado no chão, depois de uma preparação
  #               (golpes cuja animação acontece no alvo, como Thunder Shock)
  #   :buff       efeito em si mesmo ou no campo (atributos, cura, clima, terreno, telas)
  #   :hazard     joga armadilhas (Spikes, Stealth Rock...) no chão perto do alvo
  #   :noop       ainda sem versão em tempo real
  MoveSpec = Struct.new(
    :id, :name, :type, :category, :power, :kind,
    :range,    # alcance em pixels (corpo a corpo, avanço, projétil, feixe, área)
    :width,    # raio do projétil ou meia-largura do feixe
    :speed,    # velocidade do projétil (px/s)
    :windup,   # preparação antes do golpe sair (s)
    :cooldown, # recarga (s)
    :effect,   # Hash: status, chance, user_stages, target_stages, heal, fixed, hits, recoil
    :anim,     # animação do Fire Ash (preenchida no jogo por 035_move_anims.rb), ou nil
    :contact,  # golpe de contato (flag "a"): Spiky Shield e afins revidam
    keyword_init: true
  )

  # Código de função do Essentials v19 -> efeito.
  # chance: nil = usa effect_chance do golpe (0 = sempre, para golpes de status).
  # As chaves estão descritas em docs/B2-golpes-tempo-real.md.
  EFFECTS = {
    "003" => { status: :SLEEP },     "004" => { status: :SLEEP },   # Yawn vira sono direto
    "005" => { status: :POISON },    "006" => { status: :POISON },  # Toxic simplificado
    "007" => { status: :PARALYSIS }, "008" => { status: :PARALYSIS },
    "009" => { status: :PARALYSIS }, "00A" => { status: :BURN },
    "00B" => { status: :BURN },      "00C" => { status: :FROZEN },
    "00D" => { status: :FROZEN },    "00E" => { status: :FROZEN },
    "013" => { status: :CONFUSED },  "014" => { status: :CONFUSED },
    "015" => { status: :CONFUSED },
    "01C" => { user_stages: { atk: 1 } },  "01D" => { user_stages: { def: 1 } },
    "01E" => { user_stages: { def: 1 } },  "01F" => { user_stages: { spe: 1 } },
    "020" => { user_stages: { spa: 1 } },  "024" => { user_stages: { atk: 1, def: 1 } },
    "025" => { user_stages: { atk: 1, def: 1 } },   # Coil
    "026" => { user_stages: { atk: 1, spe: 1 } }, "027" => { user_stages: { atk: 1, spa: 1 } },
    "028" => { user_stages: { atk: 1, spa: 1 } }, "029" => { user_stages: { atk: 1 } },  # Hone Claws
    "02A" => { user_stages: { def: 1, spd: 1 } },
    "02B" => { user_stages: { spa: 1, spd: 1, spe: 1 } }, "02C" => { user_stages: { spa: 1, spd: 1 } },
    "02D" => { user_stages: { atk: 1, def: 1, spa: 1, spd: 1, spe: 1 } },          # Ancient Power
    "02E" => { user_stages: { atk: 2 } },  "02F" => { user_stages: { def: 2 } },
    "030" => { user_stages: { spe: 2 } },  "031" => { user_stages: { spe: 2 } },  # Autotomize
    "032" => { user_stages: { spa: 2 } },
    "033" => { user_stages: { spd: 2 } },
    "036" => { user_stages: { atk: 1, spe: 2 } },  # Shift Gear
    "037" => { acupressure: true },
    "038" => { user_stages: { def: 3 } },  "039" => { user_stages: { spa: 3 } },
    "03A" => { belly_drum: true },
    "03B" => { user_stages: { atk: -1, def: -1 }, always_self: true },
    "03C" => { user_stages: { def: -1, spd: -1 }, always_self: true },
    "03D" => { user_stages: { def: -1, spd: -1, spe: -1 }, always_self: true },
    "03E" => { user_stages: { spe: -1 }, always_self: true },
    "03F" => { user_stages: { spa: -2 }, always_self: true },
    "041" => { status: :CONFUSED, target_stages: { atk: 2 } },  # Swagger
    "042" => { target_stages: { atk: -1 } }, "043" => { target_stages: { def: -1 } },
    "044" => { target_stages: { spe: -1 } }, "045" => { target_stages: { spa: -1 } },
    "046" => { target_stages: { spd: -1 } }, "04A" => { target_stages: { atk: -1, def: -1 } },
    "04B" => { target_stages: { atk: -2 } },
    "04C" => { target_stages: { def: -2 } }, "04D" => { target_stages: { spe: -2 } },
    "04E" => { target_stages: { spa: -2 }, gender_only: true },  # Captivate
    "04F" => { target_stages: { spd: -2 } },
    "049" => { defog: true },
    "050" => { clear_target: true },
    "052" => { swap: [:atk, :spa] }, "053" => { swap: [:def, :spd] },
    "054" => { swap: [:atk, :def, :spa, :spd, :spe] }, "161" => { swap: [:spe] },
    "055" => { psych_up: true },
    "056" => { side: { mist: 15.0 } },
    "057" => { power_trick: true },
    "058" => { split: [:atk, :spa] }, "059" => { split: [:def, :spd] },
    "05A" => { pain_split: true },
    "05B" => { side: { tailwind: 12.0 } },
    "05C" => { mimic: true }, "05D" => { mimic: true },
    "05E" => { type_self: :first_move }, "05F" => { type_self: :resist_last },
    "060" => { type_self: :camouflage }, "062" => { type_self: :copy_target },
    "061" => { type_target: [:WATER] }, "142" => { type_target: [:GHOST], add_type: true },
    "143" => { type_target: [:GRASS], add_type: true }, "197" => { type_target: [:PSYCHIC] },
    "063" => { no_ability: true }, "064" => { insomnia: true }, "065" => { no_ability: true },
    "066" => { no_ability: true }, "067" => { no_ability: true }, "068" => { no_ability: true },
    "069" => { transform: true },
    "06A" => { fixed: 20 }, "06B" => { fixed: 40 }, "06D" => { fixed: :level },
    "06C" => { fixed: :half_target }, "06E" => { fixed: :endeavor }, "06F" => { fixed: :psywave },
    "070" => { ohko: true },
    "071" => { counter: 0 }, "072" => { counter: 1 }, "073" => { counter: :any },
    "0D4" => { counter: :bide },
    "075" => { hits_semi: [:dive] }, "076" => { hits_semi: [:dig] },
    "077" => { hits_semi: [:fly] }, "078" => { hits_semi: [:fly], flinch: true },
    "095" => { hits_semi: [:dig], power_fn: :magnitude }, "11B" => { hits_semi: [:fly] },
    "11C" => { hits_semi: [:fly] },
    "07B" => { power_fn: :venoshock }, "07C" => { power_fn: :smelling_salts },
    "07D" => { power_fn: :wake_up_slap }, "07E" => { power_fn: :facade }, "07F" => { power_fn: :hex },
    "080" => { power_fn: :brine }, "081" => { power_fn: :revenge }, "082" => { power_fn: :assurance },
    "084" => { power_fn: :revenge }, "086" => { power_fn: :acrobatics }, "087" => { power_fn: :weather_ball },
    "089" => { power_fn: :return }, "08A" => { power_fn: :frustration }, "08B" => { power_fn: :eruption },
    "08C" => { power_fn: :wring_out }, "08D" => { power_fn: :gyro_ball }, "08E" => { power_fn: :stored_power },
    "08F" => { power_fn: :punishment }, "091" => { power_fn: :fury_cutter }, "092" => { power_fn: :fury_cutter },
    "094" => { power_fn: :present }, "097" => { power_fn: :trump_card }, "098" => { power_fn: :flail },
    "099" => { power_fn: :electro_ball }, "09A" => { power_fn: :low_kick }, "09B" => { power_fn: :heavy_slam },
    "0D3" => { power_fn: :fury_cutter },
    "09C" => { nothing: :ally }, "117" => { nothing: :ally }, "120" => { nothing: :ally },
    "138" => { nothing: :ally }, "11D" => { nothing: :ally }, "11E" => { nothing: :ally },
    "16A" => { nothing: :ally }, "16B" => { nothing: :ally }, "17B" => { nothing: :ally },
    "001" => { nothing: :splash }, "133" => { nothing: :splash }, "134" => { nothing: :splash },
    "157" => { nothing: :splash },
    "09D" => { field: { mud_sport: 15.0 } }, "09E" => { field: { water_sport: 15.0 } },
    "118" => { field: { gravity: 10.0 } }, "11F" => { field: { trick_room: 10.0 } },
    "124" => { field: { wonder_room: 10.0 } }, "0F9" => { no_item: true }, "146" => { nothing: :splash },
    "0A0" => { always_crit: true },
    "0A1" => { side: { lucky_chant: 15.0 } },
    "022" => { user_stages: { spe: 1 } },  "034" => { user_stages: { spe: 1 } },
    "047" => { target_stages: { spe: -1 } }, "048" => { target_stages: { spe: -1 } },
    "0A2" => { side: { reflect: 15.0 } },  "0A3" => { side: { light_screen: 15.0 } },
    "167" => { side: { reflect: 15.0, light_screen: 15.0 } },
    "01A" => { side: { safeguard: 15.0 } },
    "0A5" => { homing: true }, "139" => { target_stages: { atk: -1 } },
    "13A" => { target_stages: { atk: -1, spa: -1 } }, "13C" => { target_stages: { spa: -1 } },
    "13D" => { target_stages: { spa: -2 } }, "147" => { pierce_protect: true }, "13B" => { pierce_protect: true },
    "0A6" => { lock_on: true },
    "0A7" => { identify: :GHOST }, "0A8" => { identify: :DARK },
    "0A9" => { ignore_def_stages: true },
    "0AB" => { protect: 0.6 }, "0AC" => { protect: 0.6 }, "149" => { protect: 0.6 }, "14A" => { protect: 0.6 },
    "0AD" => { pierce_protect: true },
    "0AE" => { call: :mirror_move }, "0AF" => { call: :copycat }, "0B0" => { call: :me_first },
    "0B3" => { call: :nature_power }, "0B4" => { call: :sleep_talk }, "0B5" => { call: :assist },
    "0B6" => { call: :metronome },
    "0B1" => { magic_coat: 1.5 }, "0B2" => { magic_coat: 1.5 },
    "0B7" => { torment: 5.0 }, "0B8" => { imprison: true }, "0B9" => { disable: 6.0 },
    "0BA" => { taunt: 6.0 }, "0BB" => { heal_block: 10.0 }, "0BC" => { encore: 5.0 },
    "0BE" => { hits: 2, status: :POISON }, "0BF" => { hits: 3 }, "188" => { hits: 3, always_crit: true },
    "17C" => { hits: 2 }, "175" => { hits: 2, flinch: true },
    "0C2" => { recharge: 1.0 },
    "0C3" => { charge: 0.8 }, "0C4" => { charge: 0.8, solar: true }, "0C5" => { charge: 0.8 },
    "0C6" => { charge: 0.8 }, "0C7" => { charge: 0.8, flinch: true },
    "0C8" => { charge: 0.8, user_stages: { def: 1 }, always_self: true },
    "191" => { charge: 0.8, user_stages: { spa: 1 }, always_self: true },
    "14E" => { charge: 1.0, user_stages: { spa: 2, spd: 2, spe: 2 } },
    "0C9" => { semi: :fly }, "0CA" => { semi: :dig }, "0CB" => { semi: :dive }, "0CC" => { semi: :fly },
    "0CD" => { semi: :phantom, pierce_protect: true }, "14D" => { semi: :phantom, pierce_protect: true },
    "0CE" => { semi: :fly },
    "0CF" => { bind: 4.0 }, "0D0" => { bind: 4.0, hits_semi: [:dive] }, "181" => { bind: 4.0, target_stages: { def: -1, spd: -1 } },
    "0D2" => { rampage: true },
    "0D6" => { heal: 0.5 }, "0D7" => { wish: 0.5 },
    "0DB" => { ingrain: 15.0 },
    "0DE" => { drain: 0.5, needs_sleep: true }, "14F" => { drain: 0.75 },
    "0DF" => { heal_target: 0.5 }, "16E" => { heal_target: 0.5 },
    "0E0" => { self_faint: true }, "196" => { self_faint: true },
    "0E1" => { fixed: :final_gambit, self_faint: true },
    "0E2" => { target_stages: { atk: -2, spa: -2 }, self_faint: true },
    "0E3" => { healing_wish: true }, "0E4" => { healing_wish: true },
    "0E5" => { perish: true }, "0E6" => { grudge: 3.0 }, "0E7" => { destiny_bond: 3.0 },
    "0E9" => { false_swipe: true },
    "0EC" => { knockback: 90 },
    "0ED" => { baton_pass: true }, "0EE" => { switch_out: true },
    "151" => { target_stages: { atk: -1, spa: -1 }, switch_out: true },
    "0EF" => { trap: true }, "17D" => { trap: true }, "152" => { trap: true },
    "0F0" => {}, "0F2" => { no_item: true }, "0F3" => { no_item: true },
    "0F6" => { no_item: true }, "0F8" => { no_item: true }, "18F" => { no_item: true },
    "0FF" => { weather: :SUN }, "100" => { weather: :RAIN }, "101" => { weather: :SAND }, "102" => { weather: :HAIL },
    "103" => { hazard: :spikes }, "104" => { hazard: :toxic_spikes }, "105" => { hazard: :stealth_rock },
    "153" => { hazard: :sticky_web },
    "10A" => { break_screens: true },
    "10B" => { crash: 0.5 },
    "10C" => { substitute: true },
    "10E" => { spite: 4 }, "198" => { spite: 3 },
    "10F" => { nightmare: true },
    "110" => { rapid_spin: true, user_stages: { spe: 1 }, always_self: true },
    "111" => { delayed: true },
    "115" => { focus_punch: true, charge: 0.8 }, "116" => { sucker_punch: true },
    "119" => { magnet_rise: 10.0 }, "11A" => { telekinesis: 8.0 },
    "121" => { foul_play: true }, "122" => { use_def: true }, "177" => { body_press: true },
    "123" => { synchronoise: true }, "125" => {},
    "012" => { flinch: true, chance: 100, first_only: true }, "174" => { first_only: true },
    "00F" => { flinch: true }, "010" => { flinch: true }, "011" => { flinch: true, sleep_usable: true },
    "017" => { status: :TRI },
    "135" => { status: :FROZEN, freeze_dry: true },
    "13E" => { grass_stages: { atk: 1, spa: 1 } }, "13F" => { grass_stages: { def: 1 } },
    "137" => { user_stages: { def: 1, spd: 1 } }, "15C" => { user_stages: { atk: 1, spa: 1 } },
    "18E" => { user_stages: { atk: 1, def: 1 } },
    "140" => { target_stages: { atk: -1, spa: -1, spe: -1 }, if_poisoned: true },
    "141" => { topsy: true },
    "14B" => { protect: 1.0, protect_kind: :kings_shield }, "14C" => { protect: 1.0, protect_kind: :spiky },
    "168" => { protect: 1.0, protect_kind: :baneful }, "180" => { protect: 1.0, protect_kind: :obstruct },
    "150" => { fell_stinger: true },
    "159" => { status: :POISON, target_stages: { spe: -1 } },
    "15B" => { cure_target: true, heal: 0.5 },
    "15D" => { spectral_thief: true },
    "160" => { strength_sap: true },
    "162" => { burn_up: true },
    "16D" => { heal: 0.5 },
    "170" => { hp_cost: 0.5 }, "199" => { hp_cost: 0.5 },
    "179" => { user_stages: { atk: 1, def: 1, spa: 1, spd: 1, spe: 1 }, hp_cost: 0.33 },
    "17F" => { user_stages: { atk: 1, def: 1, spa: 1, spd: 1, spe: 1 } },
    "17A" => { court_change: true },
    "183" => { user_stages: { def: 2 } }, "184" => { nothing: :splash },
    "186" => { target_stages: { spe: -1 } },
    "189" => { heal: 0.25, cure_self: true },
    "018" => { cure_self: true }, "019" => { cure_self: true },
    "15A" => {},
    "016" => { attract: true }, "01B" => { psycho_shift: true },
    "154" => { terrain: :ELECTRIC }, "155" => { terrain: :GRASSY }, "156" => { terrain: :MISTY },
    "173" => { terrain: :PSYCHIC },
    "0D5" => { heal: 0.5 }, "0D8" => { heal: 0.5, weather_heal: true },
    "0DD" => { drain: 0.5 },
    "023" => { user_stages: { crit: 2 } },
    "051" => { haze: true },
    "021" => { user_stages: { spd: 1 } },           # Charge
    "035" => { user_stages: { atk: 2, spa: 2, spe: 2, def: -1, spd: -1 } },  # Shell Smash
    "10D" => { user_stages: { atk: 1, def: 1, spe: -1 } },  # Curse (sem a versão fantasma)
    "112" => { user_stages: { def: 1, spd: 1 } },   # Stockpile
    "114" => { heal: 0.5 },                         # Swallow
    "0DA" => { heal: 0.25 },                        # Aqua Ring (cura de uma vez)
    "17E" => { heal: 0.25 },                        # Life Dew
    "15E" => { user_stages: { crit: 3 } },          # Laser Focus
    "040" => { status: :CONFUSED, target_stages: { spa: 1 } },  # Flatter
    "0E8" => { endure: 1.5 },                       # Endure: aguenta com 1 PV
    "0AA" => { protect: 1.0 },           # Protect/Detect: invencível por 1 s
    "0D9" => { heal: 1.0, rest: true },  # Rest: cura tudo e dorme
    "0DC" => { leech: true },            # Leech Seed
    "0EA" => { flee: true },             # Teleport: foge da batalha selvagem
    "0EB" => { force_out: true },        # Roar/Whirlwind: espanta o selvagem
    "0FA" => { recoil: 0.25 }, "0FB" => { recoil: 0.33 }, "0FC" => { recoil: 0.5 },
    "0FD" => { recoil: 0.33, status: :PARALYSIS }, "0FE" => { recoil: 0.33, status: :BURN }
  }

  # Efeitos que agem em quem usa (o golpe vira :buff) e os que precisam acertar o alvo.
  SELF_KEYS = %i[user_stages heal protect flee haze rest weather terrain side field cure_self substitute
                 belly_drum hp_cost wish ingrain magnet_rise destiny_bond grudge call nothing perish
                 healing_wish baton_pass lock_on transform type_self acupressure power_trick defog
                 magic_coat psych_up no_ability no_item imprison grass_stages court_change endure].freeze
  TARGET_KEYS = %i[status target_stages leech force_out disable encore taunt torment spite identify
                   pain_split swap split type_target heal_target nightmare telekinesis heal_block
                   trap clear_target cure_target strength_sap topsy mimic insomnia attract
                   spectral_thief psycho_shift].freeze

  DASH_CODES = %w[0FA 0FB 0FC 0FD 0FE].freeze

  # Ajustes à mão por ID do golpe (sobrescrevem os campos calculados).
  OVERRIDES = {
    STRUGGLE: { kind: :melee, effect: { recoil: 0.25 } }
  }

  module_function

  # data: Hash com :id, :name, :type, :category (0 físico, 1 especial, 2 status),
  #       :power, :function_code, :effect_chance, :target, :flags, :priority
  def classify(data)
    code   = data[:function_code].to_s.upcase
    flags  = data[:flags].to_s
    target = data[:target].to_s
    power  = data[:power].to_i
    cat    = data[:category].to_i
    id     = data[:id].to_s
    effect = (EFFECTS[code] || {}).dup
    chance = data[:effect_chance].to_i
    if cat == 2 || chance <= 0
      effect[:chance] ||= 100
    else
      effect[:chance] ||= chance
    end
    if effect[:user_stages] && power > 0
      effect[:self_chance] = effect[:always_self] || chance <= 0 ? 100 : chance
    end
    contact = flags.include?("a")
    sound   = flags.include?("k")
    area    = %w[AllNearOthers AllNearFoes AllFoes AllBattlers].include?(target)
    foeish  = %w[NearOther Other NearFoe RandomNearFoe].include?(target)
    has_target = TARGET_KEYS.any? { |k| effect[k] }
    has_self   = SELF_KEYS.any? { |k| effect[k] }

    kind =
      if cat == 2
        if effect[:hazard] then :hazard
        elsif has_target && foeish then :status
        elsif has_target && area then :debuff
        elsif has_self then :buff
        else :noop
        end
      elsif effect[:semi] || effect[:delayed]
        :strike
      elsif (area || sound) && !effect[:homing]   # Swift: disparo que persegue, não área
        :pulse
      elsif contact && (DASH_CODES.include?(code) || data[:priority].to_i > 0)
        :dash
      elsif contact
        :melee
      elsif id =~ /BEAM|RAY|CANNON|BLAST/
        :beam
      else
        :projectile
      end

    spec = MoveSpec.new(
      id: data[:id], name: data[:name], type: data[:type], category: cat,
      power: power, kind: kind, effect: effect, contact: contact,
      range: 0, width: 0, speed: 0, windup: 0.2, cooldown: 1.0
    )
    case kind
    when :melee      then spec.range = 34;  spec.width = 0;  spec.windup = 0.12
    when :dash       then spec.range = 110; spec.width = 0;  spec.windup = 0.08
    when :projectile then spec.range = 260; spec.width = 10; spec.windup = 0.15; spec.speed = 560
    when :beam       then spec.range = 270; spec.width = 9;  spec.windup = 0.45
    when :pulse      then spec.range = 78;  spec.width = 0;  spec.windup = 0.3
    when :status     then spec.range = 230; spec.width = 9;  spec.windup = 0.2;  spec.speed = 260
    when :debuff     then spec.range = 100; spec.width = 0;  spec.windup = 0.2
    when :hazard     then spec.range = 200; spec.width = 36; spec.windup = 0.35
    when :strike     then spec.range = 220; spec.width = 26; spec.windup = 0.8
    when :buff, :noop then spec.range = 0;  spec.windup = 0.3
    end
    spec.windup = 1.2 if effect[:delayed]
    spec.windup = (spec.windup + effect[:charge]).round(2) if effect[:charge]
    spec.windup = (spec.windup + 0.5).round(2) if effect[:ohko]
    spec.cooldown =
      if power > 0 then (0.45 + power / 70.0).round(2)
      elsif effect[:weather] || effect[:terrain] || effect[:side] || effect[:field] || kind == :hazard then 6.0
      elsif kind == :buff then 4.0
      else 3.0
      end
    spec.cooldown = [spec.cooldown, 4.0].max if effect[:recharge] || effect[:ohko]
    (OVERRIDES[data[:id].to_s.to_sym] || {}).each { |k, v| spec[k] = v }
    spec
  end

  # Spec do Struggle, usado quando nenhum golpe tem PP.
  # Golpe de dano cuja animação acontece no alvo (Thunder Shock, Thunderbolt...):
  # sai em linha reta e acerta na hora quem estiver na linha (fácil de mirar).
  def to_zap(spec)
    spec.kind = :beam
    spec.width = 14
    spec.windup = 0.15
    spec.range = 260
    spec
  end

  # Vira "cai no ponto": golpes de status cuja animação acontece no alvo (Thunder Wave...).
  def to_strike(spec)
    spec.kind = :strike
    spec.width = 22
    spec.windup = [spec.windup, 0.45].max
    spec.range = 230 if spec.range.to_i < 100
    spec
  end

  def struggle_spec
    classify(id: :STRUGGLE, name: "Struggle", type: :NORMAL, category: 0, power: 50,
             function_code: "0FA", target: "NearOther", flags: "ab", priority: 0)
  end
end
