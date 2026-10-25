#===============================================================================
############################## SS ZONE MOVES ###################################
#===============================================================================
# For 5 rounds, creates a Normal Zone which powers up Normal type moves.
# (Normal Wish)
#===============================================================================
class PokeBattle_Move_SZ00 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Normal
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Normal)
  end
end



#===============================================================================
# For 5 rounds, creates a Ice Zone which powers up Ice type moves.
# (Ice Wish)
#===============================================================================
class PokeBattle_Move_SZ01 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Ice
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Ice)
  end
end



#===============================================================================
# For 5 rounds, creates a Fighting Zone which powers up Fighting type moves.
# (Fighting Wish)
#===============================================================================
class PokeBattle_Move_SZ02 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Fighting
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Fighting)
  end
end



#===============================================================================
# For 5 rounds, creates a Poison Zone which powers up Poison type moves.
# (Poison Wish)
#===============================================================================
class PokeBattle_Move_SZ03 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Poison
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Poison)
  end
end



#===============================================================================
# For 5 rounds, creates a Normal Zone which powers up Ground type moves.
# (Ground Wish)
#===============================================================================
class PokeBattle_Move_SZ04 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Ground
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Ground)
  end
end



#===============================================================================
# For 5 rounds, creates a Normal Zone which powers up Flying type moves.
# (Flying Wish)
#===============================================================================
class PokeBattle_Move_SZ05 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Flying
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Flying)
  end
end



#===============================================================================
# For 5 rounds, creates a Normal Zone which powers up Bug type moves.
# (Bug Wish)
#===============================================================================
class PokeBattle_Move_SZ06 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Bug
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Bug)
  end
end



#===============================================================================
# For 5 rounds, creates a Normal Zone which powers up Rock type moves.
# (Rock Wish)
#===============================================================================
class PokeBattle_Move_SZ07 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Rock
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Rock)
  end
end



#===============================================================================
# For 5 rounds, creates a Ghost Zone which powers up Ghost type moves.
# (Ghost Wish)
#===============================================================================
class PokeBattle_Move_SZ08 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Ghost
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Ghost)
  end
end



#===============================================================================
# For 5 rounds, creates a Dragon Zone which powers up Dragon type moves.
# (Dragon Wish)
#===============================================================================
class PokeBattle_Move_SZ09 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Dragon
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Dragon)
  end
end



#===============================================================================
# For 5 rounds, creates a Dark Zone which powers up Dark type moves.
# (Dark Wish)
#===============================================================================
class PokeBattle_Move_SZ10 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Dark
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Dark)
  end
end



#===============================================================================
# For 5 rounds, creates a Steel Zone which powers up Fairy type moves.
# (Fairy Wish)
#===============================================================================
class PokeBattle_Move_SZ11 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Steel
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Steel)
  end
end



#===============================================================================
# For 5 rounds, creates a Fairy Zone which powers up Fairy type moves.
# (Fairy Wish)
#===============================================================================
class PokeBattle_Move_SZ12 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if @battle.field.zone == :Fairy
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartZone(user, :Fairy)
  end
end


