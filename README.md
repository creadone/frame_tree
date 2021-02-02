# FrameTree

It's a prototype of a fast in-memory tree-like structure to store and retrieve values from the counters through a rolling time-frame/window. FrameTree was created to reduce unnecessary database queries and to provide data to a sparkline from ui-component dataGrid in one of my projects. At the moment some features have been hardcoded, in particular the Frame, but in the future this is planned to rewrite more flexible.

## Features:

* FT is fast. Batch insert of 50 000 ordered items by 100 in batch took 425 ms and mixed 390 ms., for batch get 390 and 170 ms. accordingly. Update by previously inserted keys (no need to create new objects) took 150 ms. for both.
* FT is simple. Only built-in Ruby objects, limited set of base operations: get/set and get_batch/set_batch, data can be dumped to well-known format MessagePack.

## Structure:

The FrameTree consists of four levels:
* Tree — starting point and set of management methods. The Tree keeps a list of existing branches:
```
+-----------+------+
| Branch ID | Size |
+-----------+------+
|         0 | 12   |
|         1 | 10   |
|         2 | 10   |
|         3 | 10   |
|         4 | 10   |
|         5 | 10   |
|         6 | 10   |
|         7 | 10   |
|         8 | 10   |
|         9 | 10   |
|        10 | 10   |
+-----------+------+
```

* Branch — section like partition in DB to store number of frames. The main role of the branchs is to increase the lookup speed. Testing has shown that it is most efficient to set the maximum number of branches to 1/5 of the total amount of data. Each branch keeps a list of existing frames:

```
+----------+---+---+---+---+---+---+---+---+
| Frame ID | T | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
+----------+---+---+---+---+---+---+---+---+
|    40000 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
|        0 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
|    30000 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
|    10000 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
|    50000 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
|    20000 | 2 | 0 | 0 | 0 | 0 | 0 | 0 | 2 |
+----------+---+---+---+---+---+---+---+---+
```

* Frame — group of counters like a table
* Counter — simple class with increment, decrement and replace operations.

## Install
```
gem install frame_tree --pre
```

## Usage

```Ruby
require 'frame_tree'

FrameTree.setup do |s|
  s.max_branches = 2_000    # Max possible branches, better 1/5 of the total
  s.frame_length = 6        # Number of days for which values are stored
  s.data_path    = '/tmp'   # Path to directory to drop dumps
end

# Init
storage = FrameTree::Tree.new :db_name

# Insert only key (will be considered an increment)
storage.set 13441946 # => 1

# Output values will be in the format [total, sum of 7 day, sum of 6 day, sum of 5 day, ..., sum of current day]
# total — is not a sum of 7 days, it's just value that will be incrementing.
storage.get 13441946 # => [1, 0, 0, 0, 0, 0, 0, 1]

# Will return ordered arrays of counters value
storage.get_batch [key1, key2, key3, ...]

# will return array of total of each key
storage.set_batch [key1, key2, key3, ...]

# Dump data to file
storage.dump('path_to_file')

# Load data from file
storage.restore('path_to_file')
```