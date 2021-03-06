module Canfig
  module Instance
    def configuration
      @configuration ||= Canfig::OpenConfig.new
    end

    def configure(&block)
      configuration.configure &block
    end
  end
end
