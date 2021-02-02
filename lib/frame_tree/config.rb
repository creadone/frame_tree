module FrameTree
  class << self
    attr_accessor :config
  end

  class Config
    attr_accessor :frame_length
    attr_accessor :branches_num
    attr_accessor :data_path

    def initialize
      @frame_length = 6
      @branches_num = 1
      @data_path    = '/tmp'
    end
  end

  def self.config
    @config ||= Config.new
  end

  def self.setup
    yield(config)
  end
end