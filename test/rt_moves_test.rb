# Usa cada um dos 1.069 golpes (dos dois lados) por 6 s de luta simulada, para achar erros
# de execução em qualquer efeito. Uso: LANG=C.UTF-8 ruby test/rt_moves_test.rb
src = File.read(File.expand_path("rt_sim_test.rb", __dir__), encoding: "UTF-8")
eval(src.split('fails = 0')[0], binding, File.expand_path('rt_sim_test.rb', __dir__))
ids = MOVES.keys
errs = Hash.new { |h, k| h[k] = [] }
ids.each_with_index do |id, n|
  begin
    s = RTB::Sim.new(arena: [0, 0, 416, 288], walkable: ->(x, y) { true }, type_mult: method(:type_mult),
                     rng: Random.new(n), spec_lookup: ->(i, side) { spec_for(i) },
                     random_spec: ->(side) { spec_for(ids.sample(random: Random.new(n))) })
    a = PkmnStub.new('A', 40, [:NORMAL, :FLYING], [120, 60, 50, 60, 50, 60], [id.to_sym, :TACKLE])
    b = PkmnStub.new('B', 40, [:WATER], [120, 60, 50, 60, 50, 60], [id.to_sym, :EMBER])
    fa = s.add(RTB::Fighter.new(a, 0, [spec_for(id), spec_for(:TACKLE)], 100, 100))
    fb = s.add(RTB::Fighter.new(b, 1, [spec_for(id), spec_for(:EMBER)], 160, 100))
    200.times do |i|
      s.update(0.03, { 0 => { mx: 1.0, my: 0.0, use: i % 2 } })
      s.events.clear
      [fa, fb].each { |f| raise "NaN" if f.x.nan? || f.y.nan? || f.hp < 0 || f.hp > f.totalhp }
    end
  rescue => e
    errs["#{e.class}: #{e.message[0, 90]} @ #{e.backtrace[0].sub(/.*rt_battle\//, '')}"] << id
  end
end
puts "golpes: #{ids.size}, erros: #{errs.values.sum(&:size)}"
errs.each { |k, v| puts "#{k}\n   #{v.first(8).join(', ')} (#{v.size})" }
exit(errs.empty? ? 0 : 1)
