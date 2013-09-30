
# Neo4j::Friendships

neo4j-friendships is a Ruby Gem for Ruby On Rails (ROR) that allows you to use neo4j database to store users relationships and suggest friends based on current relationships.

## Installation

Add this line to your application's Gemfile:

	gem 'neography'
    gem 'neo4j-friendships'

And then execute:

    $ bundle
    $ rails g friendship User
Replace User with the user model name
## Usage

### Setup

Allow a model to act as friend:

    class User < ActiveRecord::Base
      ...
      acts_as_friend
      ...
    end

***

### Configuration

Configuration of your Neo4j server can be defined in

	/config/initializers/neo4j_friendships.rb

as follows(Default):

	Neo4j::Friendships.configure do |config|
	  config.protocol       = "http://"
	  config.server         = "localhost"
	  config.port           = 7474
	  config.directory      = ""  # prefix this path with '/' 
	  config.cypher_path    = "/cypher"
	  config.gremlin_path   = "/ext/GremlinPlugin/graphdb/execute_script"
	  config.log_file       = "neography.log"
	  config.log_enabled    = false
	  config.max_threads    = 20
	  config.authentication = nil  # 'basic' or 'digest'
	  config.username       = nil
	  config.password       = nil
	  config.parser         = MultiJsonParser
	end

And you can change it to match your server configuration.
***


### acts_as_friend Methods

Create new user

    @user = User.new
    @user.save ## a node has been created for that user

Send friendship request from @user to @user2

	@user.friend @user2

Accept friendship request from @user to @user2

	@user2.accept_request @user

Reject friendship request from @user to @user2

	@user2.reject_request @user

Check if there is a friend request from @user to @user2

	@user.request_to? @user2 
	## or
	@user2.request_from? @user

Get users friends

	@user.friends

Break current friendship between @user and @user2

	@user.unfriend @user2
	## or
	@user2.unfriend @user

Get suggestions for friendships from friends of friends

	@user.suggestions

Force creating a friendship between @user and @user2

	@user.make_mutual_friends @user2
	## or
	@user2.make_mutual_friends @user

You can get the user node if you want to use Neography to implement custom methods

	@user.node

***

## TO-DO

1- Provide Tests for acts_as_follower methods
2- Feel free to send suggestions to tarek.samni [at] gmail.com


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Copyright

Copyright (c) 2013 Tarek N. Elsamni --  Released under the MIT license.