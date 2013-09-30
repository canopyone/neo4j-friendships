module Neo4j
  module Friendships
    module Friend
      extend ActiveSupport::Concern
      included do
        after_create { create_node }
        after_initialize { self.neo = Neography::Rest.new(Neo4j::Friendships.configuration.instance_values)}
        cattr_accessor :neo
        attr_accessor :node_id

        ## Create nodes for new records
        ## @user = User.new
        ## @user.save 
        ## Here a node is created after save
        def create_node
          @node = Neography::Node.create({}, self.neo)
          self["node_id"] = @node.neo_id
          self.save
        end

        ## Send friendship request
        ## Usage ex. :
        ## @user1 = User.new
        ## @user1.save
        ## @user2 = User.new
        ## @user2.save
        ## @user1.friend @user2
        ## A Friend request has been initiated
        def friend other_user
          ## get nodes
          my_node = self.node
          other_node = other_user.node
          ## create relationship of type friendship_request
          friendship_request = Neography::Relationship.create("friendship_request", my_node, other_node)
          friendship_request[:rejected] = false
          friendship_request[:accepted] = false
          return friendship_request
        end

        ## Check if there is a friend request initiated by self to other
        ## Usage ex. :
        ## @user1.request_to? @user2
        def request_to? other_user
          ## get nodes
          my_node = self.node
          other_node = other_user.node

          ## get friendrequests initiated from self to other
          friendship_requests = my_node.rels("friendship_request").outgoing.to_a.keep_if do |relation|
            (relation.end_node == other_node and relation.rejected == false and relation.accepted == false)
          end
          (friendship_requests.count > 0)
        end

        ## Check if there is a friend request initiated by other to self
        ## Usage ex. :
        ## @user1.request_from? @user2
        def request_from? other_user
          ## get nodes
          my_node = self.node
          other_node = other_user.node

          ## get friendrequests initiated from other to self
          friendship_requests = my_node.rels("friendship_request").incoming.to_a.keep_if do |relation|
            (relation.start_node == other_node and relation.rejected == false and relation.accepted == false)
          end
          (friendship_requests.count > 0)
        end

        ## Check if there is a friend relationship
        ## Usage ex. :
        ## @user1.is_friend? @user2
        def is_friend? other_user
          ## get nodes
          my_node = self.node
          other_node = other_user.node
          path = self.neo.get_paths(my_node, other_node, {"type"=> "friends"}, depth=2, algorithm="allSimplePaths")
          (path.count > 0)
        end

        ## Get my friends
        ## Usage ex. :
        ## @user1.friends
        ## return active (accepted) friendships
        def friends
          friends = []
          my_node = self.node
          my_node.rels("friends").incoming.to_a.each do |friendship|
            friends << self.class.where("node_id = ?" ,friendship.start_node.neo_id).first
          end
          return friends
        end

        ## accept friendship request if there is a pending request
        ## Usage ex. :
        ## @user1.accept_request @user2
        ## accept friendship request if there is an existing one
        def accept_request other_user
          ## get nodes
          my_node = self.node

          ## check if there is a previous request
          if (self.request_from?(other_user))
            ## get friendrequests initiated from other to self
            friendship_requests = my_node.rels("friendship_request").incoming.to_a.keep_if do |relation|
              relation.accepted = true
            end
            self.make_mutual_friends other_user
          end
        end

        ## reject friendship request if there is a pending request 
        ## Usage ex. :
        ## @user1.reject_request @user2
        ## reject friendship request if there is an existing one
        def reject_request other_user
          ## get nodes
          my_node = self.node

          ## check if there is a previous request
          if (self.request_from?(other_user))
            ## get friendrequests initiated from other to self
            friendship_requests = my_node.rels("friendship_request").incoming.to_a.keep_if do |relation|
              relation.rejected = true
            end
          end
        end

        ## break current friendship
        ## Usage ex. :
        ## @user1.unfriend @user2
        def unfriend other_user
          ## check if they are already friends
          if self.is_friend? other_user
            ## get nodes
            my_node = self.node

            ## delete friendships from self to other
            friendship_requests = my_node.rels("friends").incoming.to_a.each do |relation|
              self.neo.delete_relationship(relation)
            end
            ## delete friendships from other to self
            friendship_requests = my_node.rels("friends").outgoing.to_a.each do |relation|
              self.neo.delete_relationship(relation)
            end
          end
        end

        ## get suggestions for friendships from friends of friends
        ## Usage ex. :
        ## @user1.suggestions
        def suggestions
          ## get nodes ids of friends of friends
          nodes_id = self.neo.traverse(self.node,
                "nodes", 
                {"order" => "breadth first", 
                 "uniqueness" => "node global", 
                 "relationships" => {"type"=> "friends", 
                                     "direction" => "in"}, 
                 "return filter" => {"language" => "javascript",
                                     "body" => "position.length() == 2;"},
                 "depth" => 2}).map{|n| Neography::Node.load(n["self"]).neo_id}

          ## get users data from nodes
          self.class.where("node_id in (?)" ,nodes_id)
        end

        ## force make mutual friends without any validations
        ## Usage ex. :
        ## @user1.make_mutual_friends @user2
        def make_mutual_friends other_user
          ## get nodes
          my_node = self.node
          other_node = other_user.node

          ## mutual friends relationships
          self.neo.create_relationship("friends", my_node, other_node)
          self.neo.create_relationship("friends", other_node, my_node)
        end

        ## return node of self
        ## Usage ex.:
        ## @user1.node
        def node
          get_node self["node_id"]
        end

        private
        def get_node node_id
          Neography::Node.load(node_id, self.neo)
        end
      end
    end
  end
end