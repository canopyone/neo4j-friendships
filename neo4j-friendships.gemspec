# coding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require 'neo4j/friendships/version'

Gem::Specification.new do |spec|
  spec.name          = "neo4j-friendships"
  spec.version       = Neo4j::Friendships::VERSION
  spec.authors       = ["Tarek N. Elsamni"]
  spec.email         = ["tarek.samni@gmail.com"]
  spec.description   = "neo4j-friendships is a Ruby Gem that allows you to use neo4j database to store users data, relationships and suggest friends based on current relationships."
  spec.summary       = "neo4j-friendships is a Ruby Gem for friendships management and suggestions using neo4j database."
  spec.homepage      = "https://github.com/tareksamni/neo4j-friendships"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "neography"
  spec.add_runtime_dependency "neography"
end
