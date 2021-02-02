module FrameTree
  class << self
    attr_accessor :config
  end

  class Config
    attr_accessor :frame_length
    attr_accessor :max_branches
    attr_accessor :data_path
    attr_accessor :tree

    def initialize
      @frame_length = 6
      @max_branches = 1
      @data_path    = '/tmp'
      @tree = nil
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.setup
    yield(config)
  end
end