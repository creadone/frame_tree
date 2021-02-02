require_relative '../lib/frame_tree'
require 'benchmark'

FrameTree.setup do |s|
  s.max_branches = 10_000
end

ordered_ids = []
(0..50_000).each_slice(100){|pack| ordered_ids.push pack }

mixed_ids = []
(0..50_000).to_a.shuffle.each_slice(100){|pack| mixed_ids.push pack }

setup = {
  ordered: ordered_ids,
  mixed: mixed_ids
}

setup.each do |(name, set)|
  storage = nil
  storage = FrameTree::Tree.new :db_name

  result_01 = Benchmark.realtime{
    set.each do |batch|
      storage.set_batch batch
    end
  }
  puts "#{name} set_batch: \t #{(result_01 * 1000).to_i} ms"

  result_02 = Benchmark.realtime{
    set.each do |batch|
      storage.get_batch batch
    end
  }
  puts "#{name} get_batch: \t #{(result_02 * 1000).to_i} ms"

  result_03 = Benchmark.realtime{
    set.each do |batch|
      storage.set_batch batch
    end
  }
  puts "#{name} set_batch: \t #{(result_03 * 1000).to_i} ms"
  puts storage.branches[0].to_table
end



# db = FrameTree::Tree.new :db_name
#
# r_set_ordered = Benchmark.realtime{
#   ids_ordered.each do |pack|
#     db.set_batch(pack)
#   end
# }
#
# r_set_mixed = Benchmark.realtime{
#   ids_mixed.each do |pack|
#     db.set_batch(pack)
#   end
# }
#
# r_get_ordered = Benchmark.realtime{
#   ids_ordered.each do |pack|
#     db.get_batch(pack)
#   end
# }
#
# r_get_mixed = Benchmark.realtime{
#   ids_mixed.each do |pack|
#     db.get_batch(pack)
#   end
# }
#
# puts "SET ordered \t #{(r_set_ordered * 1000).to_i}ms"
# puts "SET mixed \t #{(r_set_mixed * 1000).to_i}ms"
# puts "GET ordered \t #{(r_get_mixed * 1000).to_i}ms"
# puts "GET mixed \t #{(r_get_mixed * 1000).to_i}ms"
#
