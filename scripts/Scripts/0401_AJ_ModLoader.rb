#==============================================================================
# Pokémon Ash's Journey — carregador de Mods
# Carrega Mods/**/*.rb em ordem alfabética, depois dos plugins do Essentials.
# O código novo do projeto vive nesses arquivos de texto (ver o repositório).
#==============================================================================
module AJMods
  LOADED = []
  FAILED = []
  ERROR_LOG = "Mods/carregamento_erros.txt"

  # Um arquivo com erro não derruba o jogo: fica registrado em ERROR_LOG e o
  # resto continua. Com qualquer falha, a batalha em tempo real se desliga
  # sozinha (o jogo segue por turno).
  def self.load_all
    Dir.glob("Mods/**/*.rb").sort.each do |path|
      begin
        code = File.read(path, encoding: "UTF-8")
        eval(code, TOPLEVEL_BINDING, path)
        LOADED.push(path)
      rescue ScriptError, StandardError => e
        FAILED.push(path)
        begin
          File.open(ERROR_LOG, "a") do |f|
            f.puts "#{Time.now} #{path}: #{e.class}: #{e.message}"
            (e.backtrace || []).first(8).each { |l| f.puts "    #{l}" }
            f.puts
          end
        rescue StandardError
          nil
        end
      end
    end
  end

  def self.ok?
    FAILED.empty?
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
