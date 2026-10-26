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
  #   :buff       efeito em si mesmo (atributos, cura)
  #   :noop       ainda sem versão em tempo real (armadilhas, clima, campo)
  MoveSpec = Struct.new(
    :id, :name, :type, :category, :power, :kind,
    :range,    # alcance em pixels (corpo a corpo, avanço, projétil, feixe, área)
    :width,    # raio do projétil ou meia-largura do feixe
    :speed,    # velocidade do projétil (px/s)
    :windup,   # preparação antes do golpe sair (s)
    :cooldown, # recarga (s)
    :effect,   # Hash: status, chance, user_stages, target_stages, heal, fixed, hits, recoil
    keyword_init: true
  )

  # Código de função do Essentials v19 -> efeito.
  # chance: nil = usa effect_chance do golpe (0 = sempre, para golpes de status).
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
    "026" => { user_stages: { atk: 1, spe: 1 } }, "027" => { user_stages: { atk: 1, spa: 1 } },
    "028" => { user_stages: { atk: 1, spa: 1 } }, "02A" => { user_stages: { def: 1, spd: 1 } },
    "02B" => { user_stages: { spa: 1, spd: 1, spe: 1 } }, "02C" => { user_stages: { spa: 1, spd: 1 } },
    "02E" => { user_stages: { atk: 2 } },  "02F" => { user_stages: { def: 2 } },
    "030" => { user_stages: { spe: 2 } },  "032" => { user_stages: { spa: 2 } },
    "033" => { user_stages: { spd: 2 } },
    "042" => { target_stages: { atk: -1 } }, "043" => { target_stages: { def: -1 } },
    "044" => { target_stages: { spe: -1 } }, "045" => { target_stages: { spa: -1 } },
    "046" => { target_stages: { spd: -1 } }, "04B" => { target_stages: { atk: -2 } },
    "04C" => { target_stages: { def: -2 } }, "04D" => { target_stages: { spe: -2 } },
    "04F" => { target_stages: { spd: -2 } },
    "06A" => { fixed: 20 }, "06B" => { fixed: 40 }, "06D" => { fixed: :level },
    "0BD" => { hits: 2 }, "0C0" => { hits: 3 },
    "0D5" => { heal: 0.5 }, "0D6" => { heal: 0.5 }, "0D8" => { heal: 0.5 },
    "0DD" => { drain: 0.5 },
    # Aproximações de efeitos que não existem em tempo real (precisão, evasão, telas)
    "022" => { user_stages: { spe: 1 } },  "034" => { user_stages: { spe: 1 } },
    "047" => { target_stages: { spe: -1 } }, "048" => { target_stages: { spe: -1 } },
    "0A2" => { user_stages: { def: 1 } },  "0A3" => { user_stages: { spd: 1 } },
    "023" => { user_stages: { crit: 2 } },
    "051" => { haze: true },
    "0AA" => { protect: 1.0 },           # Protect/Detect: invencível por 1 s
    "0D9" => { heal: 1.0, rest: true },  # Rest: cura tudo e dorme
    "0DC" => { leech: true },            # Leech Seed
    "0EA" => { flee: true },             # Teleport: foge da batalha selvagem
    "0EB" => { force_out: true },        # Roar/Whirlwind: espanta o selvagem
    "0FA" => { recoil: 0.25 }, "0FB" => { recoil: 0.33 }, "0FC" => { recoil: 0.5 },
    "0FD" => { recoil: 0.33, status: :PARALYSIS }, "0FE" => { recoil: 0.33, status: :BURN }
  }

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
    if effect[:status] || effect[:target_stages] || effect[:leech] || effect[:force_out]
      chance = data[:effect_chance].to_i
      effect[:chance] = (cat == 2 || chance <= 0) ? 100 : chance
    end
    contact = flags.include?("a")
    sound   = flags.include?("k")
    area    = %w[AllNearOthers AllNearFoes AllFoes AllBattlers].include?(target)

    kind =
      if cat == 2
        if effect[:haze]
          :buff
        elsif %w[User UserSide UserAndAllies UserOrNearAlly].include?(target)
          (effect[:user_stages] || effect[:heal] || effect[:protect] || effect[:flee]) ? :buff : :noop
        elsif area
          effect[:target_stages] ? :debuff : (effect[:status] ? :pulse : :noop)
        elsif %w[NearOther Other NearFoe RandomNearFoe].include?(target)
          (effect[:status] || effect[:target_stages] || effect[:leech] || effect[:force_out]) ? :status : :noop
        else
          :noop # FoeSide (armadilhas), BothSides (clima/terreno) etc.
        end
      elsif area || sound
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
      power: power, kind: kind, effect: effect,
      range: 0, width: 0, speed: 0, windup: 0.2, cooldown: 1.0
    )
    case kind
    when :melee      then spec.range = 34;  spec.width = 0;  spec.windup = 0.12
    when :dash       then spec.range = 110; spec.width = 0;  spec.windup = 0.08
    when :projectile then spec.range = 250; spec.width = 7;  spec.windup = 0.18; spec.speed = 300
    when :beam       then spec.range = 270; spec.width = 9;  spec.windup = 0.45
    when :pulse      then spec.range = 78;  spec.width = 0;  spec.windup = 0.3
    when :status     then spec.range = 230; spec.width = 9;  spec.windup = 0.2;  spec.speed = 260
    when :debuff     then spec.range = 100; spec.width = 0;  spec.windup = 0.2
    when :buff, :noop then spec.range = 0;  spec.windup = 0.3
    end
    spec.cooldown =
      if power > 0 then (0.45 + power / 70.0).round(2)
      elsif kind == :buff then 4.0
      else 3.0
      end
    (OVERRIDES[data[:id].to_s.to_sym] || {}).each { |k, v| spec[k] = v }
    spec
  end

  # Spec do Struggle, usado quando nenhum golpe tem PP.
  def struggle_spec
    classify(id: :STRUGGLE, name: "Struggle", type: :NORMAL, category: 0, power: 50,
             function_code: "0FA", target: "NearOther", flags: "ab", priority: 0)
  end
end
