require 'active_support/core_ext/module/attribute_accessors'

module Canfig
  module Module
    def self.included(base)
      base.send :cattr_reader, :configuration
      base.send :class_variable_set, :@@configuration, Canfig::OpenConfig.new
      base.send :extend, ClassMethods
    end

    module ClassMethods
      def configure(&block)
        (send :class_variable_get, :@@configuration).configure &block
      end
    end
  end
end
