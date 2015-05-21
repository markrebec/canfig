module Canfig
  class OpenConfig < Config
    def allowed?(opt)
      true
    end

    def to_h
      @state.to_h
    end
  end
end
