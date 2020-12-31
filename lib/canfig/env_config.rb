module Canfig
  class EnvConfig < OpenConfig
    attr_reader :namespace

    def configure_with_args(argh)
      save_state! do
        argh.symbolize_keys.each { |key,val| env(key, val) }
      end
    end

    def get(key, default=nil, &block)
      super || env(key, default, &block)
    end

    def env(key, default=nil, &block)
      @state[key.to_sym] ||= begin
        key = key.to_s.underscore.upcase
        key = key.gsub(/^#{namespace}/, '') if namespace
        val = ENV.fetch("#{namespace}#{key}", default, &block)
        val && ENV.key?(val.to_s) ? env(val, default, &block) : val
      end
    end

    protected

    def initialize(namespace=nil, **attributes, &block)
      @namespace = namespace ? "#{namespace.to_s.underscore.upcase.gsub(/_$/, '')}_" : namespace
      super(**attributes, &block)
    end
  end
end
