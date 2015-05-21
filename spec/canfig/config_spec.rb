require 'spec_helper'

RSpec.describe Canfig::Config do
  describe '#initialize' do
    context 'when passed a list of keys' do
      subject { Canfig::Config.new(:foo, :bar, :baz) }

      it 'adds those keys to the allowed keys' do
        expect(subject.allowed?(:foo)).to be_true
        expect(subject.allowed?(:bar)).to be_true
        expect(subject.allowed?(:baz)).to be_true
      end
    end

    context 'when passed a hash of keys and values' do
      subject { Canfig::Config.new(foo: 'foo', bar: 'bar', baz: 'baz') }

      it 'adds those keys to the allowed keys' do
        expect(subject.allowed?(:foo)).to be_true
        expect(subject.allowed?(:bar)).to be_true
        expect(subject.allowed?(:baz)).to be_true
      end
    end

    context 'when passed a list of keys and a hash of keys and values' do
      subject { Canfig::Config.new(:foo, :bar, baz: 'baz') }

      it 'adds those keys to the allowed keys' do
        expect(subject.allowed?(:foo)).to be_true
        expect(subject.allowed?(:bar)).to be_true
        expect(subject.allowed?(:baz)).to be_true
      end
    end
  end

  describe '#set' do
    context 'when the key is allowed' do
      subject { Canfig::Config.new(:foo) }

      it 'sets the key/value pair' do
        subject.set(:foo, 'bar')
        expect(subject.get(:foo)).to eql('bar')
      end
    end

    context 'when the key is not allowed' do
      subject { Canfig::Config.new(:baz) }

      it 'raises a NoMethodError' do
        expect { subject.set(:foo, 'bar') }.to raise_exception(NoMethodError)
      end
    end
  end

  describe '#get' do
    context 'when the key is allowed' do
      subject { Canfig::Config.new(:baz, foo: 'bar') }

      it 'returns the corresponding value' do
        expect(subject.get(:foo)).to eql('bar')
      end

      context 'when the key is not set' do
        it 'returns nil' do
          expect(subject.get(:baz)).to be_nil
        end
      end
    end

    context 'when the key is not allowed' do
      subject { Canfig::Config.new(:baz) }

      it 'raises a NoMethodError' do
        expect { subject.get(:foo) }.to raise_exception(NoMethodError)
      end
    end
  end

  describe '#to_h' do
    subject { Canfig::Config.new(:foo, bar: 'bar', baz: 'baz') }

    it 'returns a hash' do
      expect(subject.to_h).to be_an_instance_of(Hash)
    end

    it 'contain all allowed keys' do
      [:foo, :bar, :baz].each do |key|
        expect(subject.to_h.keys).to include(key)
      end
    end
  end

  describe '#configure_with_args' do
    subject { Canfig::Config.new(:foo, bar: 'bar', baz: 'baz') }

    context 'when the passed keys are allowed' do
      it 'sets the key/value pairs passed the hash' do
        subject.configure_with_args({foo: 1, bar: 2})
        expect(subject.get(:foo)).to eql(1)
        expect(subject.get(:bar)).to eql(2)
      end
    end

    context 'when the passed keys are not allowed' do
      it 'raises a NoMethodError' do
        expect { subject.configure_with_args({abc: '123'}) }.to raise_exception(NoMethodError)
      end
    end
  end

  describe '#configure_with_block' do
    subject { Canfig::Config.new(:foo, bar: 'bar', baz: 'baz') }

    it 'accepts a block' do
      expect { subject.configure_with_block { |config| } }.to_not raise_exception
    end

    it 'executes the block with instance_eval' do
      conf = nil
      subject.configure_with_block { |config| conf = config }
      expect(conf).to eql(subject)
    end
  end

  describe '#configure' do
    subject { Canfig::Config.new(:foo, bar: 'bar', baz: 'baz') }

    it 'returns self' do
      expect(subject.configure).to eql(subject)
    end

    it 'accepts a hash and a block' do
      subject.configure foo: 'foo' do |config|
        config.bar = 'baz'
        config.baz = 'bar'
      end

      expect(subject.get(:foo)).to eql('foo')
      expect(subject.get(:bar)).to eql('baz')
      expect(subject.get(:baz)).to eql('bar')
    end
  end

  context 'when referencing option keys' do
    subject { Canfig::Config.new(:foo, bar: 'bar', baz: 'baz') }

    context 'that are allowed' do
      context 'using getter methods' do
        it 'returns the value' do
          expect(subject.bar).to eql('bar')
        end
      end

      context 'using setter methods' do
        it 'sets the passed value to the key' do
          subject.bar = 'foo'
          expect(subject.bar).to eql('foo')
        end
      end
    end

    context 'that are not allowed' do
      context 'using getter methods' do
        it 'returns the value' do
          expect { subject.abc }.to raise_exception(NoMethodError)
        end
      end

      context 'using setter methods' do
        it 'sets the passed value to the key' do
          expect { subject.abc = 123 }.to raise_exception(NoMethodError)
        end
      end
    end
  end

  context 'when saving state' do
    subject { Canfig::Config.new(:foo, bar: 'bar', baz: 'baz') }

    describe '#changed' do
      it 'returns a hash' do
        subject.configure do |config|
          config.foo = 'test'
          config.bar = 1
        end

        expect(subject.changed).to be_an_instance_of(Hash)
      end

      it 'contains the changed keys' do
        subject.configure do |config|
          config.foo = 'test'
          config.bar = 1
        end

        [:foo, :bar].each do |key|
          expect(subject.changed.keys).to include(key)
        end
      end

      it 'contains only the changed keys' do
        subject.configure do |config|
          config.foo = 'test'
          config.bar = 1
        end

        expect(subject.changed.keys).to_not include(:baz)
      end

      it 'contains the old and new values' do
        subject.configure do |config|
          config.foo = 'test'
          config.bar = 1
        end

        expect(subject.changed[:foo]).to eql([nil,'test'])
        expect(subject.changed[:bar]).to eql(['bar',1])
      end
    end
  end

end
