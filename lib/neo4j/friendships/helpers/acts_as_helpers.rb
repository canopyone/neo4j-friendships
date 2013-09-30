require 'active_support/concern'

module Neo4j
  module Friendships
    module ActsAsHelpers
      extend ActiveSupport::Concern

      module ClassMethods
      def acts_as_friend(opts = {})
        include Neo4j::Friendships::Friend
      end
    end
  end
end
end