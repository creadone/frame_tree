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