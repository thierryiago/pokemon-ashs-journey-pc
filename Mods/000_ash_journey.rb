#==============================================================================
# Pokémon Ash's Journey — configuração geral do mod
#==============================================================================
module AshJourney
  VERSION = "0.1.0-b0"

  # Batalha em tempo real (plano v0.5, seção 7). false = todas as batalhas por turno.
  REALTIME_WILD_BATTLES = true
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
