module FrameTree
  class Branch
    attr_reader :size
    attr_accessor :frames

    class << self
      def from_hash id, data
        branch = Branch.new id
        frames = data.each_with_object({}) do |(idx, val), acc|
          acc[idx] = Frame.from_hash idx, val
        end
        branch.frames = frames
        branch
      end
    end

    def initialize id
      @id     = id
      @size   = 0
      @frames = {}
    end

    def get(key)
      if @frames.has_key?(key)
        @frames[key].get
      end
    end

    def set(key, val = nil)
      if @frames.key? key
        @frames[key].set val
      else
        @frames[key] = Frame.new @frames.size + 1
        @frames[key].set val
      end
      @size += 1
    end

    # def [](key)
    #   get key
    # end

    def frame(id)
      @frames[id]
    end

    def to_hash
      @frames.each_with_object({}) do |(k,v), acc|
        acc[k] = v.to_h
      end
    end

    def to_s
      "<FrameTree::Branch @id=#{@id},
        @size=#{@size},
        @frames=[#{@frames.keys.first(3).join(', ')}, ...]>"
    end

    def to_table
      Helper.render do |rows, headings|
        headings << ['Frame ID', 'T', 0, 1, 2, 3, 4, 5, 6]
        @frames.each do |(id, frame)|
          rows << [id, frame.values].flatten
        end
      end
    end

    def each
      @frames.each do |frame|
        yield frame
      end
    end
  end
end
