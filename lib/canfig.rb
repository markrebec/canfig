require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/keys'
require 'active_support/inflector'
require 'canfig/version'
require 'canfig/yaml'
require 'canfig/config'
require 'canfig/open_config'
require 'canfig/env_config'
require 'canfig/module'
require 'canfig/class'
require 'canfig/instance'

module Canfig
  def self.new(*args, &block)
    Canfig::Config.new *args, &block
  end

  def self.open(*args, &block)
    Canfig::OpenConfig.new *args, &block
  end
end
