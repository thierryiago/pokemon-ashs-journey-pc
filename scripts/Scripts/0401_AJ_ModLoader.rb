#==============================================================================
# Pokémon Ash's Journey — carregador de Mods
# Carrega Mods/**/*.rb em ordem alfabética, depois dos plugins do Essentials.
# O código novo do projeto vive nesses arquivos de texto (ver o repositório).
#==============================================================================
module AJMods
  LOADED = []

  def self.load_all
    Dir.glob("Mods/**/*.rb").sort.each do |path|
      code = File.read(path, encoding: "UTF-8")
      eval(code, TOPLEVEL_BINDING, path)
      LOADED.push(path)
    end
  end
end

module PluginManager
  class << self
    unless method_defined?(:aj_runPlugins_original)
      alias aj_runPlugins_original runPlugins
      def runPlugins
        aj_runPlugins_original
        AJMods.load_all
      end
    end
  end
end
