#==============================================================================
# Pokémon Ash's Journey — dados do jogo sobrescritos por texto
#
# Em vez de regravar os .dat, as mudanças de conteúdo (ex.: encontros de Kanto
# no padrão do FireRed, fase F3) ficam em arquivos Ruby legíveis em
# Mods/data/*.rb, aplicados logo depois que o jogo carrega os .dat.
# Apagar o arquivo volta o dado ao original do Fire Ash.
#
# Exemplo (Mods/data/kanto_encounters.rb):
#   AJData.encounters(76, step_chances: { Land: 21 }, types: {
#     Land: [[50, :PIDGEY, 2, 5], [50, :RATTATA, 2, 4]]
#   })
#==============================================================================
module AJData
  @encounters = []

  class << self
    # map: ID do mapa; version: 0 (padrão); types: { Land: [[chance, espécie, nível mín., nível máx.], ...] }
    def encounters(map, version: 0, step_chances: {}, types: {})
      (@encounters ||= []).push(map: map, version: version, step_chances: step_chances, types: types)
    end

    def apply
      (@encounters || []).each do |h|
        key = format("%d_%d", h[:map], h[:version]).to_sym
        GameData::Encounter::DATA[key] = GameData::Encounter.new(h.merge(id: key))
      end
    end
  end
end

module GameData
  class << self
    unless method_defined?(:aj_original_load_all)
      alias aj_original_load_all load_all
      def load_all
        aj_original_load_all
        AJData.apply
      end
    end
  end
end
