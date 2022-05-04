module HTTPError
  class Forbidden < StandardError
    def initialize(msg = "Forbidden")
      super(msg)
    end
  end
end
