$:.push File.expand_path("../lib", __FILE__)
require "canfig/version"

Gem::Specification.new do |s|
  s.name        = "canfig"
  s.version     = Canfig::VERSION
  s.summary     = "Dead simple canned configuration for gems or whatever"
  s.description = "Dead simple canned configuration for gems or whatever"
  s.authors     = ["Mark Rebec"]
  s.email       = ["mark@markrebec.com"]
  s.files       = Dir["lib/**/*"]
  s.test_files  = Dir["spec/**/*"]
  s.homepage    = "http://github.com/markrebec/canfig"

  s.add_dependency "activesupport"

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
