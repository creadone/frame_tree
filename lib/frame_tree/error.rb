module FrameTree
  class WrongInputType < ArgumentError
    def initialize(msg = 'Key or Value must be Integer')
      super(msg)
    end
  end

  class WrongDataLength < ArgumentError
    def initialize(msg = 'Data must be the same length as Frame')
      super(msg)
    end
  end

  class MissingOption < ArgumentError
    def initialize(option)
      @msg = "Missing config option #{option}"
      super(@msg)
    end
  end
end
