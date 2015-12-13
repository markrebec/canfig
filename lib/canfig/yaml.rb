module Canfig
  class YAML
    attr_reader :file

    def initialize(file)
      @file = file
    end

    def load
      @data ||= ::YAML.load_file(file).symbolize_keys
    end
    alias_method :data, :load

    def reload
      @data = nil
      self.load
    end

    def write
      File.open(file, 'w') do |f|
        f.write(::YAML.dump(data))
      end
    end
  end
end
