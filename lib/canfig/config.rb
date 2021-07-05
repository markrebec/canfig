module Canfig
  class Config

    def configure(argh={}, file=nil, &block)
      save_state! do
        configure_with_file file unless file.nil?
        configure_with_args argh
        configure_with_block &block
      end
      self
    end

    def configure_with_file(file)
      save_state! do
        configure_with_args(Canfig::YAML.new(file).load)
      end
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

    def thread_configs
      Thread.current[:_canfig_configs] ||= {}
      Thread.current[:_canfig_configs]
    end

    def state
      thread_configs[object_id] ||= {}
      thread_configs[object_id]
    end

    def set(key, val)
      raise NoMethodError, "undefined method `#{key.to_s}=' for #{self.to_s}" unless allowed?(key)

      save_state! do
        state[key] = val
      end
    end

    def env(key, default=nil, &block)
      state[key] ||= begin
        val = ENV.fetch(key.to_s.underscore.upcase, default, &block)
        val = default if val.blank?
        val = env(val, default, &block) if val && ENV.key?(val.to_s)
        val = eval(val) if val == 'true' || val == 'false'
        val
      end
    end

    def clear(*keys)
      save_state! do
        keys.each { |key| state[key] = nil }
      end
    end

    def []=(key, val)
      set key, val
    end

    def get(key, default=nil, &block)
      raise NoMethodError, "undefined method `#{key.to_s}' for #{self.to_s}" unless allowed?(key)
      state_val = state[key]
      return (block_given? ? yield : default) if state_val.nil?
      state_val
    end

    def [](key)
      get key
    end

    def to_h
      Hash[@allowed.map { |key| [key, state[key]] }]
    end

    def changed
      Hash[@allowed.map { |key| [key, [@saved_state[key], state[key]]] if @saved_state[key] != state[key] }.compact]
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
        return set(opt, args.first) if allowed?(opt)
      else
        return get(meth, *args, &block) if allowed?(meth)
      end

      super
    end

    protected

    def initialize(*args, **options, &block)
      @allowed = (args.map(&:to_sym) + options.symbolize_keys.keys).uniq
      enable_state_saves!
      configure options, &block
    end
  end
end
