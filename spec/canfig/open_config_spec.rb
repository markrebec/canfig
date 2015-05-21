require 'spec_helper'

RSpec.describe Canfig::OpenConfig do
  describe '#to_h' do
    subject { Canfig::OpenConfig.new() }

    it 'returns a hash' do
      expect(subject.to_h).to be_an_instance_of(Hash)
    end

    it 'contain all set keys' do
      subject.set :foo, 'foo'
      subject.set :bar, 'bar'
      subject.set :baz, 'baz'
      [:foo, :bar, :baz].each do |key|
        expect(subject.to_h.keys).to include(key)
      end
    end
  end
end
