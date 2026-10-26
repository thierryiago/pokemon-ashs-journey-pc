# Exporta a árvore de mapas e os eventos de cada mapa (Data/MapNNN.rxdata) para texto em maps/.
# Uso: ruby tools/dump_maps.rb   (rodar na raiz do repositório)
# Saída: maps/_tree.txt (hierarquia) e maps/NNN_<nome>.yaml (tamanho, tileset, eventos com comandos).
# Os tiles não são exportados: para ver o mapa use tools/map_to_json.rb + tools/render_map.py.
require 'yaml'
require 'fileutils'
require_relative 'lib/rpg_stubs'

def iv(o, k) = o.instance_variable_get(:"@#{k}")
def str(s) = s.to_s.dup.force_encoding('UTF-8').scrub

def plain(o)
  case o
  when Array then o.map { |v| plain(v) }
  when Hash then o.to_h { |k, v| [k.to_s, plain(v)] }
  when String then str(o)
  when Symbol then o.to_s
  when Numeric, true, false, nil then o
  else
    h = { '_class' => o.class.name }
    o.instance_variables.each { |v| h[v.to_s.delete('@')] = plain(o.instance_variable_get(v)) }
    h
  end
end

# Comandos de evento do RPG Maker XP: código numérico + parâmetros. Mantemos os dois e o recuo.
def command(c)
  { 'i' => iv(c, :indent), 'code' => iv(c, :code), 'p' => plain(iv(c, :parameters)) }
end

def page(pg)
  cond = iv(pg, :condition)
  g = iv(pg, :graphic)
  {
    'condition' => {
      'switch1' => (iv(cond, :switch1_valid) ? iv(cond, :switch1_id) : nil),
      'switch2' => (iv(cond, :switch2_valid) ? iv(cond, :switch2_id) : nil),
      'variable' => (iv(cond, :variable_valid) ? [iv(cond, :variable_id), iv(cond, :variable_value)] : nil),
      'self_switch' => (iv(cond, :self_switch_valid) ? iv(cond, :self_switch_ch) : nil)
    }.compact,
    'graphic' => str(iv(g, :character_name)),
    'trigger' => iv(pg, :trigger),
    'commands' => iv(pg, :list).map { |c| command(c) }
  }
end

root = File.expand_path('..', __dir__)
out = File.join(root, 'maps')
FileUtils.rm_rf(out)
FileUtils.mkdir_p(out)

infos = Marshal.load(File.binread(File.join(root, 'Data/MapInfos.rxdata')))
kids = Hash.new { |h, k| h[k] = [] }
infos.each { |id, i| kids[iv(i, :parent_id)] << id }
tree = []
walk = lambda do |id, depth|
  kids[id].sort_by { |c| iv(infos[c], :order) }.each do |c|
    tree << format('%s%03d %s', '  ' * depth, c, str(iv(infos[c], :name)))
    walk.call(c, depth + 1)
  end
end
walk.call(0, 0)
File.write(File.join(out, '_tree.txt'), tree.join("\n") + "\n")

infos.keys.sort.each do |id|
  path = File.join(root, format('Data/Map%03d.rxdata', id))
  next unless File.exist?(path)
  m = Marshal.load(File.binread(path))
  name = str(iv(infos[id], :name))
  events = iv(m, :events).values.sort_by { |e| iv(e, :id) }.map do |e|
    { 'id' => iv(e, :id), 'name' => str(iv(e, :name)), 'x' => iv(e, :x), 'y' => iv(e, :y),
      'pages' => iv(e, :pages).map { |pg| page(pg) } }
  end
  doc = { 'id' => id, 'name' => name, 'parent' => iv(infos[id], :parent_id),
          'width' => iv(m, :width), 'height' => iv(m, :height), 'tileset' => iv(m, :tileset_id),
          'bgm' => str(iv(iv(m, :bgm), :name)), 'events' => events }
  File.write(File.join(out, format('%03d_%s.yaml', id, name.gsub(/[^\w\-]+/, '_')[0, 40])), doc.to_yaml(line_width: -1))
end
puts "#{infos.size} mapas exportados"

# Nomes das switches e variáveis globais (flags de história), de Data/System.rxdata.
sys = Marshal.load(File.binread(File.join(root, 'Data/System.rxdata')))
lines = []
iv(sys, :switches).each_with_index { |n, i| lines << format('S%04d %s', i, str(n)) if i.positive? && !str(n).empty? }
iv(sys, :variables).each_with_index { |n, i| lines << format('V%04d %s', i, str(n)) if i.positive? && !str(n).empty? }
File.write(File.join(out, '_switches_variables.txt'), lines.join("\n") + "\n")
puts "#{lines.size} switches/variáveis com nome"
