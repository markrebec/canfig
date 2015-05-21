module Canfig
  module Class
    def self.included(base)
      base.send :cattr_reader, :configuration
      base.send :class_variable_set, :@@configuration, Canfig::OpenConfig.new
      base.send :extend, Canfig::Class::ClassMethods
    end

    module ClassMethods
      def configure(&block)
        (send :class_variable_get, :@@configuration).configure &block
      end
    end
  end
end
