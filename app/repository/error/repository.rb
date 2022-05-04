module Repository
  class NoDataError < StandardError
    def initialize(msg = nil)
      super(msg)
    end
  end
end
