# Exporta os dados compilados do Essentials (Data/*.dat) para YAML legível em data/.
# Uso: ruby tools/dump_data.rb   (rodar na raiz do repositório)
# Apenas leitura: o jogo continua usando os .dat. Arquivos antigos (v17) não usados pelo v19 são ignorados.
require 'yaml'
require 'fileutils'

def defclass(path)
  mod = Object
  parts = path.split('::')
  parts.each_with_index do |p, i|
    mod = mod.const_defined?(p, false) ? mod.const_get(p, false) : mod.const_set(p, i == parts.size - 1 ? Class.new : Module.new)
  end
end

def load_dat(path)
  Marshal.load(File.binread(path))
rescue ArgumentError => e
  raise unless e.message =~ %r{undefined class/module (\S+)}
  defclass(Regexp.last_match(1))
  retry
end

# Objeto Ruby -> estrutura simples (Hash/Array/String/Number), estável para diff.
def plain(o)
  case o
  when Hash then o.each_with_object({}) { |(k, v), h| h[plain_key(k)] = plain(v) }
  when Array then o.map { |v| plain(v) }
  when Symbol then o.to_s
  when String then o.dup.force_encoding('UTF-8').scrub
  when Numeric, true, false, nil then o
  else
    h = { '_class' => o.class.name }
    o.instance_variables.each { |iv| h[iv.to_s.delete('@')] = plain(o.instance_variable_get(iv)) }
    h
  end
end

def plain_key(k) = k.is_a?(Symbol) ? k.to_s : (k.is_a?(String) || k.is_a?(Integer) ? k : k.inspect)

FILES = %w[species moves abilities items types trainers trainer_types encounters
           map_metadata metadata regional_dexes town_map map_connections
           berry_plants ribbons phone ZUD_PowerMoves].freeze

root = File.expand_path('..', __dir__)
out = File.join(root, 'data')
FileUtils.mkdir_p(out)

FILES.each do |name|
  d = load_dat(File.join(root, 'Data', "#{name}.dat"))
  if d.is_a?(Hash)
    # O Essentials guarda cada registro duas vezes (por símbolo e por número): manter uma só.
    seen = {}
    recs = d.values.reject { |v| seen[v.object_id].tap { seen[v.object_id] = true } }
    recs.sort_by! { |v| [v.instance_variable_get(:@id_number) || 0, v.instance_variable_get(:@id).to_s] }
    data = recs.map { |v| plain(v) }
  else
    data = plain(d)
  end
  File.write(File.join(out, "#{name}.yaml"), data.to_yaml(line_width: -1))
  puts format('%-16s %6d registros', name, data.is_a?(Array) ? data.size : 1)
end
