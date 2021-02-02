module FrameTree
  class Tree
    attr_reader :size
    attr_reader :name
    attr_reader :statistics
    attr_accessor :branches
    attr_accessor :config

    def initialize(name, config = FrameTree.config)
      @config       = config
      @config.tree  = self
      @name         = name
      @size         = 0
      @today        = Time.now.wday
      @branches     = {}
      @max_branches = @config.max_branches
      @statistics   = {
        get: 0, set: 0, lookup: 0,
      }
    end

    # Select and insert data
    def set(key, val = nil)
      @statistics[:set] += 1
      with_branch_for(key) do |branch|
        branch.set key, val
      end
    end

    def get(key)
      @statistics[:get] += 1
      with_branch_for(key) do |branch|
        branch.get key
      end
    end

    def set_batch(items)
      items.map do |(key, val)|
        set key, val
      end
    end

    def get_batch(keys)
      keys.map do |key|
        get key
      end
    end

    def branch(id)
      @branches[id]
    end

    # Explore structure
    def to_table
      Helper.render do |rows, headings|
        headings << ['Branch ID', 'Size']
        @branches.each do |(id, branch)|
          rows << [id, branch.size]
        end
      end
    end

    def each
      @branches.each do |branch|
        yield branch
      end
    end

    def to_hash
      @branches.each_with_object({}) do |(k,v), acc|
        acc[k] = v.to_hash
      end
    end

    def from_hash data
      @branches = data.each_with_object({}) do |(idx, values), acc|
        acc[idx] = Branch.from_hash idx, values
      end
    end

    # Dump and restore data
    def dump(file_path = nil)
      file_path ||= File.join(@config.data_path, "#{Time.now.to_i.to_s}.bin")
      File.open(file_path, 'wb') do |io|
        io << MessagePack.pack(to_hash)
      end
      file_path
    end

    def restore(file_path = nil)
      data = nil
      file_path ||= Dir.glob(File.join(@config.data_path, '*.bin')).sort.last
      File.open(file_path, 'rb') do |io|
        data = MessagePack.unpack(io.read)
      end
      from_hash data
    end

    private

    def hash(key)
      @statistics[:lookup] += 1
      key % @max_branches
    end

    def with_branch_for(key)
      index = hash key
      if @branches.has_key? index
        @branches[index]
      else
        @size += 1
        @branches[index] = Branch.new index
      end
      yield @branches[index]
    end
  end
end
