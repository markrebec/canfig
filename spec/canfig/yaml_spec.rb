require 'spec_helper'

RSpec.describe Canfig::YAML do
  subject { described_class.new('spec/fixtures/config.yml') }

  describe '#load' do
    it 'loads the file into a hash' do
      expect(subject.load).to be_a(Hash)
    end
  end

  describe '#write' do
    subject { described_class.new('spec/fixtures/test.yml') }

    before do
      FileUtils.cp 'spec/fixtures/config.yml', 'spec/fixtures/test.yml'
    end

    it 'writes the hash back to the file in YAML' do
      subject.data[:foo] = 'bar'
      subject.write
      subject.reload
      expect(subject.data[:foo]).to eq('bar')
    end

    after do
      FileUtils.rm 'spec/fixtures/test.yml'
    end
  end

  describe '#reload' do
    it 'reloads the data from the file' do
      subject.data[:foo] = 'bar'
      subject.reload
      expect(subject.data[:foo]).to eq('foo')
    end
  end
end
