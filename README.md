# Canfig

[![Build Status](https://travis-ci.org/markrebec/canfig.png)](https://travis-ci.org/markrebec/canfig)
[![Coverage Status](https://coveralls.io/repos/markrebec/canfig/badge.svg)](https://coveralls.io/r/markrebec/canfig)
[![Code Climate](https://codeclimate.com/github/markrebec/canfig.png)](https://codeclimate.com/github/markrebec/canfig)
[![Gem Version](https://badge.fury.io/rb/canfig.png)](http://badge.fury.io/rb/canfig)
[![Dependency Status](https://gemnasium.com/markrebec/canfig.png)](https://gemnasium.com/markrebec/canfig)

Dead simple canned configuration for gems or whatever.

## Getting Started

Add the gem to your Gemfile:

    gem 'canfig'

Then run `bundle install`.

Or if you want to use canfig to configure one of your gems, add it as a dependency to your gemspec and `require 'canfig'` somewhere in your gem.

## Usage

You can create a new configuration object by passing in a list of allowed options and/or a hash with defaults.

```ruby
conf = Canfig::Config.new(:foo, :bar) # new config with nil values for provided keys
conf = Canfig::Config.new(foo: 'abc', bar: 123) # new config with default values
conf = Canfig::Config.new(:foo, :bar, baz: 123) # combination of the two
```

Then you can use that object to allow further configuration of the allowed option keys with a hash or block.

```ruby
conf = Canfig::Config.new(:foo, :bar, :baz)

conf.configure(foo: 'abc', bar: 123) # with a hash

conf.configure do |config| # with a block
  config.bar = 123
  config.baz = Struct.new(:a, :b).new(1, 2)
end

conf.configure foo: 'abc' do |config| # or with both
  config.bar = 123
  config.baz = Struct.new(:a, :b).new(1, 2)
end
```

Only the option keys provided when initializing the configuration object can be accessed, and attempting to get or set any other keys will result in a `NoMethodError` (similar to a `Struct`).

If you want your configuration object to be more flexible, you can use `Canfig::OpenConfig` which allows dynamically setting and getting option keys (similar to an `OpenStruct`).

```ruby
conf = Canfig::OpenConfig.new

conf.configure foo: 'abc' do |config| # you can set whatever you want
  config.bar = 123
  config.baz = Struct.new(:a, :b).new(1, 2)
end
```

This pattern isn't all that powerful on it's own, and you might be thinking "why wouldn't I just use a Hash or an OpenStruct?"

Canfig becomes particularly useful when you need to allow configuration of a class or module that will be used in different environments and scenarios (like a ruby gem).

```ruby
module MyGem
  mattr_reader :configuration
  @@configuration = Canfig::Config.new(:foo, :bar, :baz)

  def self.configure(&block)
    @@configuration.configure &block
  end
end
```

Users of your gem could then configure it with `MyGem.configure`, for example in a rails initializer.

```ruby
MyGem.configure do |config|
  config.foo = 'abc'
  config.bar = 123
end
```

And you could check the configured options to control behavior within your gem.

```ruby
module MyGem
  class MyClass
    def do_foo?
      MyGem.configuration.foo == true
    end
  end
end
```

Canfig also comes with some easy-to-use mixins for modules, classes and instances that provide a `configuration` module/class/instance variable and a `configure` module/class/instance method (similar to the gem example above).

```ruby
module MyModule
  include Canfig::Module
end

MyModule.configuration # <Canfig::OpenConfig>
MyModule.configure { |config| config.foo = 'abc' }

class MyClass
  include Canfig::Class
end

MyClass.configuration # <Canfig::OpenConfig>
MyClass.configure { |config| config.foo = 'abc' }

class MyObject
  include Canfig::Instance
end

object = MyObject.new
object.configuration # <Canfig::OpenConfig>
object.configure { |config| config.foo = 'abc' }
```

## Custom Configs

You can create your own custom configuration classes by extending either `Canfig::Config` or `Canfig::OpenConfig` as appropriate, and defining/overriding any additional functionality you need. One handy trick is to override `initialize` to set default keys/values without requiring them to be passed in every time.

```ruby
class CustomConfig < Canfig::Config
  def initialize(*args, &block)
    # ignore the arguments that are passed in and set some custom keys and defaults
    super(:foo, :bar, baz: 'abc', &block)
  end
end

conf = CustomConfig.new # :foo => nil, :bar => nil, :baz => 'abc'
```

You can also define custom helpers to set groups of configuration options (or do anything else, really).

```ruby
class DeveloperConfig < Canfig::OpenConfig
  def enter_beast_mode!
    set :headphones, :on
    set :status, 'do_not_disturb'
  end
end

conf = DeveloperConfig.new
conf.configure do |config|
  config.enter_beast_mode!
end
```

## Contributing
1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
