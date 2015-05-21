module Canfig
  class OpenConfig < Config
    def set(key, val)
      super(key, val)
      @allowed << key unless @allowed.include?(key)
    end

    def allowed?(opt)
      true
    end
  end
end
