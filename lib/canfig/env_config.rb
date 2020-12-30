module Canfig
  class EnvConfig < OpenConfig
    attr_reader :namespace

    def initialize(namespace=nil, **options, &block)
      @namespace = namespace ? "#{namespace.to_s.underscore.upcase.gsub(/_$/, '')}_" : namespace
      super(**options, &block)
    end

    def get(key, default=nil, &block)
      super || env(key, default, &block)
    end

    def env(key, default=nil, &block)
      key = key.to_s.underscore.upcase
      key = key.gsub(/^#{namespace}/, '') if namespace
      super("#{namespace}#{key}", default, &block)
    end
  end
end
