#==============================================================================
# Batalha em tempo real — animações de golpe do Fire Ash no mapa
#
# Reaproveita as animações das batalhas por turno (Data/PkmnAnimations.rxdata +
# Graphics/Animations/*.png): o raio do Thunder Shock cai no alvo, a brasa do
# Ember viaja até ele etc. Cada "cel" da animação tem um foco:
#   1 = alvo, 2 = quem usa, 3 = linha entre os dois, 4 = tela.
# Na batalha por turno, quem usa fica em (128, 224) e o alvo em (384, 96);
# aqui as posições são convertidas para o mapa e reduzidas (ANIM_SCALE).
#==============================================================================
module RTB
  ANIM_SCALE = 0.55
  FOCUS_USER   = [128.0, 224.0]
  FOCUS_TARGET = [384.0, 96.0]

  @anim_info = {}
  @anim_sheets = {}

  class << self
    # Informações da animação de um golpe, ou nil se não houver.
    # side 0 = lado do jogador, 1 = adversário (o Essentials tem versões "OppMove").
    def anim_info(move_id, side)
      key = [move_id, side]
      return @anim_info[key] if @anim_info.key?(key)
      @anim_info[key] = begin
        found = PokeBattle_Scene.allocate.pbFindMoveAnimation(move_id, side, 0)
        anims = pbLoadBattleAnimations
        anim = found && anims && anims[found[0]]
        anim && anim.length > 0 ? describe_anim(anim) : nil
      rescue StandardError
        nil
      end
    end

    # Viaja do usuário até o alvo (cels de foco 3 com desenho)? Qual desenho usar no disparo?
    def describe_anim(anim)
      travel = nil
      on_target = false
      anim.length.times do |i|
        (anim[i] || []).each do |cel|
          next if !cel || cel[AnimFrame::PATTERN] < 0
          case cel[AnimFrame::FOCUS]
          when 3 then travel ||= cel[AnimFrame::PATTERN]
          when 1 then on_target = true
          end
        end
      end
      { anim: anim, travel_pattern: travel, on_target: on_target }
    end

    def anim_sheet(anim)
      key = [anim.graphic, anim.hue]
      bmp = @anim_sheets[key]
      return bmp if bmp && !bmp.disposed?
      @anim_sheets[key] = AnimatedBitmap.new("Graphics/Animations/" + anim.graphic, anim.hue).deanimate
    rescue StandardError
      nil
    end

    def clear_anim_sheets
      @anim_sheets.each_value { |b| b.dispose if b && !b.disposed? }
      @anim_sheets.clear
    end
  end

  #----------------------------------------------------------------------------
  # Toca uma animação de golpe no mapa.
  # mode :full = todos os cels; :target = só os do alvo (impacto de projétil).
  #----------------------------------------------------------------------------
  class MoveAnimPlayer
    TICK = 1.0 / 20   # o Essentials toca 20 quadros de animação por segundo

    def initialize(info, viewport, user_xy, target_xy, mode = :full)
      @anim = info[:anim]
      @viewport = viewport
      @user = user_xy
      @target = target_xy
      @mode = mode
      @sheet = RTB.anim_sheet(@anim)
      @sprites = []
      @t = 0.0
      @frame = -1
      @done = @sheet.nil?
    end

    def done?
      @done
    end

    def update(dt)
      return if @done
      @t += dt
      frame = (@t / TICK).floor
      return if frame == @frame
      @frame = frame
      if frame >= @anim.length
        @done = true
        @sprites.each { |s| s.visible = false }
        return
      end
      play_timing(frame)
      draw_frame(@anim[frame] || [])
    end

    def dispose
      @sprites.each(&:dispose)
      @sprites.clear
      @done = true
    end

    private

    def play_timing(frame)
      (@anim.timing || []).each do |t|
        next if t.frame != frame || t.timingType != 0
        next if !t.name || t.name == ""
        pbSEPlay(t.name, t.volume, t.pitch) rescue nil
      end
    end

    def sprite(i)
      @sprites[i] ||= Sprite.new(@viewport)
    end

    def draw_frame(cels)
      n = 0
      cels.each do |cel|
        next if !cel || cel[AnimFrame::PATTERN] < 0 || cel[AnimFrame::VISIBLE] != 1
        focus = cel[AnimFrame::FOCUS]
        next if @mode == :target && focus != 1
        x, y, rot = cel_position(cel, focus)
        s = sprite(n); n += 1
        pattern = cel[AnimFrame::PATTERN]
        s.bitmap = @sheet
        s.src_rect.set((pattern % 5) * 192, (pattern / 5) * 192, 192, 192)
        s.ox = 96; s.oy = 96
        s.zoom_x = cel[AnimFrame::ZOOMX] / 100.0 * ANIM_SCALE
        s.zoom_y = cel[AnimFrame::ZOOMY] / 100.0 * ANIM_SCALE
        s.angle = cel[AnimFrame::ANGLE] + rot
        s.mirror = cel[AnimFrame::MIRROR] > 0
        s.opacity = cel[AnimFrame::OPACITY]
        s.blend_type = cel[AnimFrame::BLENDTYPE] || 0
        s.color.set(cel[AnimFrame::COLORRED] || 0, cel[AnimFrame::COLORGREEN] || 0,
                    cel[AnimFrame::COLORBLUE] || 0, cel[AnimFrame::COLORALPHA] || 0)
        s.tone.set(cel[AnimFrame::TONERED] || 0, cel[AnimFrame::TONEGREEN] || 0,
                   cel[AnimFrame::TONEBLUE] || 0, cel[AnimFrame::TONEGRAY] || 0)
        s.x, s.y = RTB.screen_xy(x, y)
        s.z = 9500 + n
        s.visible = true
      end
      (n...@sprites.length).each { |i| @sprites[i].visible = false }
    end

    # Posição no mapa (px) e rotação extra de um cel.
    def cel_position(cel, focus)
      cx = cel[AnimFrame::X].to_f; cy = cel[AnimFrame::Y].to_f
      RTB.cel_to_map(cx, cy, focus, @user, @target)
    end
  end

  module_function

  # Converte um ponto da animação (coordenadas da batalha por turno) para o mapa.
  # Foco 3: transformação de semelhança da linha usuário->alvo da batalha para a
  # linha real no mapa (mantém a proporção ao longo da linha e gira os cels).
  def cel_to_map(cx, cy, focus, user, target)
    s = ANIM_SCALE
    case focus
    when 1
      [target[0] + (cx - FOCUS_TARGET[0]) * s, target[1] + (cy - FOCUS_TARGET[1]) * s, 0]
    when 2
      [user[0] + (cx - FOCUS_USER[0]) * s, user[1] + (cy - FOCUS_USER[1]) * s, 0]
    when 3
      sx = FOCUS_TARGET[0] - FOCUS_USER[0]; sy = FOCUS_TARGET[1] - FOCUS_USER[1]
      dx = target[0] - user[0]; dy = target[1] - user[1]
      dlen = Math.sqrt(dx * dx + dy * dy)
      if dlen < 1
        return [user[0] + (cx - FOCUS_USER[0]) * s, user[1] + (cy - FOCUS_USER[1]) * s, 0]
      end
      slen2 = sx * sx + sy * sy
      slen = Math.sqrt(slen2)
      px = cx - FOCUS_USER[0]; py = cy - FOCUS_USER[1]
      t = (px * sx + py * sy) / slen2          # posição ao longo da linha (0 = usuário, 1 = alvo)
      perp = (px * -sy + py * sx) / slen       # distância perpendicular (px da batalha)
      nx = -dy / dlen; ny = dx / dlen          # normal da linha no mapa
      rot = (Math.atan2(-dy, dx) - Math.atan2(-sy, sx)) * 180 / Math::PI
      [user[0] + dx * t + nx * perp * s, user[1] + dy * t + ny * perp * s, rot]
    else # 4: tela -> em volta do ponto médio
      mx = (user[0] + target[0]) / 2.0; my = (user[1] + target[1]) / 2.0
      [mx + (cx - 256) * s, my + (cy - 160) * s, 0]
    end
  end
end
