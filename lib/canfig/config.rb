module Canfig
  class Config

    def configure(argh={}, &block)
      save_state! do
        configure_with_args argh
        configure_with_block &block
      end
      self
    end

    def configure_with_args(argh)
      save_state! do
        argh.symbolize_keys.each { |key,val| set(key, val) }
      end
    end

    def configure_with_block(&block)
      save_state! do
        instance_eval &block if block_given?
      end
    end

    def set(key, val)
      raise NoMethodError, "undefined method `#{key.to_s}=' for #{self.to_s}" unless allowed?(key)

      save_state! do
        @state[key] = val
      end
    end

    def []=(key, val)
      set key, val
    end

    def get(key)
      raise NoMethodError, "undefined method `#{key.to_s}' for #{self.to_s}" unless allowed?(key)
      @state[key]
    end

    def [](key)
      get key
    end

    def to_h
      Hash[@allowed.map { |key| [key, @state[key]] }]
    end

    def changed
      Hash[@state.map { |key,val| [key, [@saved_state[key], val]] if @saved_state[key] != val }.compact]
    end

    def changed?(key)
      changed.key?(key)
    end

    def save_state!(&block)
      if save_state?
        @saved_state = to_h

        if block_given?
          disable_state_saves!
          begin
            yield
          ensure
            enable_state_saves!
          end
        end
      else
        yield if block_given?
      end
    end

    def enable_state_saves!
      @save_state = true
    end

    def disable_state_saves!
      @save_state = false
    end

    def save_state?
      @save_state
    end

    def allowed?(opt)
      @allowed.include?(opt)
    end

    def method_missing(meth, *args, &block)
      if meth.to_s.match(/=\Z/)
        opt = meth.to_s.gsub(/=/,'').to_sym
        return set(opt, args.first) if allowed?(meth)
      else
        return @state[meth] if allowed?(meth)
      end

      super
    end

    protected

    def initialize(*args, &block)
      options = args.extract_options!
      @allowed = (args + options.symbolize_keys.keys).uniq
      @state = {}
      enable_state_saves!
      configure options, &block
    end
  end
end
