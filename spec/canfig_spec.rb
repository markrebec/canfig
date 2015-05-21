require 'spec_helper'

RSpec.describe Canfig do
  describe '.new' do
    it 'returns a configuration object' do
      expect(subject.new).to be_an_instance_of(Canfig::Config)
    end
  end

  describe '.open' do
    it 'returns an open configuration object' do
      expect(subject.open).to be_an_instance_of(Canfig::OpenConfig)
    end
  end
end
