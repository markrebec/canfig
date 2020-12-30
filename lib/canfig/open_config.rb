module Canfig
  class OpenConfig < Config
    def set(key, val)
      @allowed << key unless @allowed.include?(key)
      super(key, val)
    end

    def allowed?(opt)
      true
    end
  end
end
