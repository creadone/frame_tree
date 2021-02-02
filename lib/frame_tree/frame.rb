module FrameTree
  class Frame
    attr_reader   :size
    attr_accessor :total
    attr_accessor :config
    attr_accessor :counters

    class << self
      def from_hash id, data
        frame = Frame.new id
        frame.total = [data.shift].to_h['total']
        frame.counters = data.each_with_object({}) do |(idx, val), acc|
          acc[idx] = Counter.new idx
          acc[idx].set val
        end
        frame
      end
    end

    def initialize(id, config: FrameTree.config)
      @config       = config
      @id           = id
      @wday         = Time.now.wday
      @size         = 0
      @total        = Counter.new :total
      @count_num    = @config.frame_length
      @counters     = setup_counters
      @last_access  = nil
    end

    def set val = nil
      update { val }
    end

    def get
      [@total.get] + @counters.values.map(&:get)
    end

    def [](idx)
      @counters[idx]
    end

    def values
      get
    end

    def to_h
      (['total'] + @counters.keys).zip(values).to_h
    end

    def to_table
      Helper.render do |rows, headers|
        headers << ['ID', 'Value']
        rows << ['T', @total.get]
        @counters.each do |(idx, value)|
          rows << [idx, value]
        end
      end
    end

    def to_s
      "<FrameTree::Frame @id=#{@id}, @size=#{@size}, @counters=[#{values.join(', ')}]>"
    end

    private

    def update
      time_now = Time.now
      current_wday = time_now.wday
      rotate_counters if @wday != current_wday
      data = yield
      if data.is_a?(Hash) || data.is_a?(Array)
        update_counters data
      else
        active_counter.incr
        @total.incr
      end
      @wday = current_wday
      @last_access = time_now.to_i
      values
    end

    def update_counters data
      data = data.values if data.is_a? Hash
      raise WrongDataLength.new unless data.size == @count_num
      raise WrongInputType.new  unless data.all?{ |val| val.is_a?(Integer) }

      @total.set data.shift
      data.each_with_index do |val, idx|
        @counters[idx].set val
      end
    end

    def rotate_counters
      @counters.shift
      tmp_hash = @counters.each_with_object({}) do |(pos, val), acc|
        acc[pos - 1] = val
      end
      tmp_hash[tmp_hash.size] = Counter.new tmp_hash.size
      @counters = tmp_hash
    end

    def setup_counters
      unless @count_num.is_a?(Integer)
        raise MissingOption.new('frame_length')
      end
      tmp_hash = {}
      (0..@count_num).each do |idx|
        tmp_hash[idx] = Counter.new idx
        @size = idx
      end
      tmp_hash
    end

    def active_counter
      counters[@count_num]
    end

  end
end
