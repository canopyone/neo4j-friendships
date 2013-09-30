module Neo4j
  module Friendships
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :protocol, :server, :port, :directory, :cypher_path, :gremlin_path, :log_file, :log_enabled, :max_threads, :authentication, :username, :password, :parser

      def initialize
        load_defaults
      end

      private
      def load_defaults
        @protocol       = "http://"
        @server         = "localhost"
        @port           = 7474
        @directory      = ""  # prefix this path with '/' 
        @cypher_path    = "/cypher"
        @gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
        @log_file       = "neography.log"
        @log_enabled    = false
        @max_threads    = 20
        @authentication = nil  # 'basic' or 'digest'
        @username       = nil
        @password       = nil
        @parser         = MultiJsonParser
      end
    end
  end
end