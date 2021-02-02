require_relative '../lib/frame_tree'
require 'benchmark'

FrameTree.setup do |s|
  s.branches_num = 2_000
  s.frame_length = 6
end

ids_ordered = []
(0..100_000).each_slice(100){|pack| ids_ordered.push pack }

ids_mixed = []
(0..100_000).to_a.shuffle.each_slice(100){|pack| ids_mixed.push pack }

db = FrameTree::Tree.new :db_name

r_set_ordered = Benchmark.realtime{
  ids_ordered.each do |pack|
    db.set_batch(pack)
  end
}

r_set_mixed = Benchmark.realtime{
  ids_mixed.each do |pack|
    db.set_batch(pack)
  end
}

r_get_ordered = Benchmark.realtime{
  ids_ordered.each do |pack|
    db.get_batch(pack)
  end
}

r_get_mixed = Benchmark.realtime{
  ids_mixed.each do |pack|
    db.get_batch(pack)
  end
}

puts "SET ordered \t #{(r_set_ordered * 1000).to_i}ms"
puts "SET mixed \t #{(r_set_mixed * 1000).to_i}ms"
puts "GET ordered \t #{(r_get_mixed * 1000).to_i}ms"
puts "GET mixed \t #{(r_get_mixed * 1000).to_i}ms"

