require "neo4j/friendships/version"

%w(
	lib/*.rb
  actors/*.rb
  config/*.rb
  helpers/*.rb
).each do |path|
  Dir["#{File.dirname(__FILE__)}/friendships/#{path}"].each { |f| require(f) }
end

ActiveRecord::Base.send :include, Neo4j::Friendships::ActsAsHelpers