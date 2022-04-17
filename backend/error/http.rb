module HTTPError
  class Forbidden < StandardError
    def initialize(msg = "Forbidden")
      super
    end
  end
end
