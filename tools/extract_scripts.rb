# Exporta Data/Scripts.rxdata e Data/PluginScripts.rxdata para arquivos .rb legíveis.
# Uso: ruby tools/extract_scripts.rb   (rodar na raiz do repositório)
# Saída: scripts/Scripts/NNNN_<nome>.rb e scripts/PluginScripts/<plugin>/<arquivo>.rb
# Apenas leitura: o jogo continua usando os .rxdata.
require 'zlib'
require 'fileutils'

def safe(name) = name.to_s.strip.gsub(/[^\w\-. \[\]]/, '_').gsub(/\s+/, '_')[0, 60]

root = File.expand_path('..', __dir__)
out = File.join(root, 'scripts')
FileUtils.rm_rf(out)

main = Marshal.load(File.binread(File.join(root, 'Data/Scripts.rxdata')))
dir = File.join(out, 'Scripts'); FileUtils.mkdir_p(dir)
index = []
main.each_with_index do |(_id, name, code), i|
  name = name.to_s.force_encoding('UTF-8')
  text = Zlib::Inflate.inflate(code).force_encoding('UTF-8')
  index << format("%04d\t%s\t%d", i, name, text.bytesize)
  next if text.strip.empty?
  File.write(File.join(dir, format('%04d_%s.rb', i, safe(name))), text)
end
File.write(File.join(out, 'Scripts_index.tsv'), index.join("\n") + "\n")

plugins = Marshal.load(File.binread(File.join(root, 'Data/PluginScripts.rxdata')))
plugins.each do |_key, meta, files|
  pdir = File.join(out, 'PluginScripts', safe(meta[:name]))
  FileUtils.mkdir_p(pdir)
  File.write(File.join(pdir, '_meta.txt'), meta.map { |k, v| "#{k}: #{v.inspect}" }.join("\n") + "\n")
  files.each do |fname, code|
    path = File.join(pdir, fname.to_s.force_encoding('UTF-8'))
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, Zlib::Inflate.inflate(code).force_encoding('UTF-8'))
  end
end
puts "Scripts: #{main.size} seções; plugins: #{plugins.size}"
