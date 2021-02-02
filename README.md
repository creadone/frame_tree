# FrameTree

It's a prototype of a fast in-memory tree-like structure to store and retrieve values from updatable counters through a rolling time-frame/window. The structure consists of four levels:Tree — starting point and set of management tools.Branch — section like partition in DB to store number of frames.Frame — group of counters like a table with methods to support counters' life cycle.Counter — simple object with increment, decrement and update operations.

```Ruby
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

# SET ordered 	 860ms
# SET mixed 	 344ms
# GET ordered 	 214ms
# GET mixed 	 214ms

```


```Ruby
require 'frame_tree'

FrameTree.setup do |s|
  s.branches_num = 2_000    # Max possible branches, better 1/5 of the total
  s.frame_length = 6        # Number of days for which values are stored
  s.data_path    = '/tmp'   # Path to directory to drop dumps
end

# Init
DB = FrameTree::Tree.new :db_name

# Insert only key (will be considered an increment)
DB.set 13441946 # => 1

# Output values will be in the format [total, sum of 7 day, sum of 6 day, sum of 5 day, ..., sum of current day]
# total — is not a sum of 7 days, it's just value that will be incrementing.
DB.get 13441946 # => [1, 0, 0, 0, 0, 0, 0, 1]

# Will return ordered arrays of counters value
DB.get_batch [key1, key2, key3, ...]

# Increment each counter of current day by passed ids,
# will return array of total of each key
DB.set_batch [key1, key2, key3, ...]

# Dump data to file
DB.dump('path_to_file')

# Load data from file
DB.restore('path_to_file')
```