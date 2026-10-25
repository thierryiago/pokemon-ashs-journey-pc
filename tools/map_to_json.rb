# Converte um mapa (Data/MapNNN.rxdata) em JSON com os tiles, para o render_map.py.
# Uso: ruby tools/map_to_json.rb 33 > /tmp/map033.json
require 'json'
require_relative 'lib/rpg_stubs'
root = File.expand_path('..', __dir__)
id = Integer(ARGV.fetch(0))
m = Marshal.load(File.binread(File.join(root, format('Data/Map%03d.rxdata', id))))
ts = Marshal.load(File.binread(File.join(root, 'Data/Tilesets.rxdata')))[m.instance_variable_get(:@tileset_id)]
t = m.instance_variable_get(:@data)
events = m.instance_variable_get(:@events).values.map do |e|
  { name: e.instance_variable_get(:@name).to_s.force_encoding('UTF-8'), x: e.instance_variable_get(:@x), y: e.instance_variable_get(:@y) }
end
puts JSON.dump(w: t.xs, h: t.ys, z: t.zs, d: t.data,
               ts: ts.instance_variable_get(:@tileset_name).to_s.force_encoding('UTF-8'),
               at: ts.instance_variable_get(:@autotile_names).map { |n| n.to_s.force_encoding('UTF-8') },
               events: events)
