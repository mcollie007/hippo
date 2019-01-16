module Hippo
  module VERSION
    MAJOR = 0
    MINOR = 5
    PATCH = 6
    BUILD = 'edge'

    STRING = [MAJOR, MINOR, PATCH, BUILD].compact.join('.')

    def self.version
      STRING unless defined?(Hippo::VERSION)
    end
  end
end
