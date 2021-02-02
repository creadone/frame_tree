module FrameTree
  class Counter
    def initialize id
      @id      = id
      @storage = 0
    end

    def get
      @storage
    end

    def set(val)
      @storage = if val.nil?
        @storage += 1
      else
        @storage += val
      end
    end

    def incr
      @storage = @storage + 1
    end

    def decr
      @storage = @storage - 1
    end

    def clear
      @storage = 0
    end

    def to_s
      "<FrameTree::Counter @id=#{@id}, @value=#{@storage}>"
    end

  end
end
