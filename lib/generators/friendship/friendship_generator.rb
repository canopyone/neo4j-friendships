class FriendshipGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("../templates", __FILE__)
 
  def copy_initializer_file
    copy_file "friendship_initializer.rb", "config/initializers/neo4j_friendships.rb"
  end

	def self.next_migration_number
		Time.now.utc.strftime("%Y%m%d%H%M%S")
	end

	def create_friendship_migration_files
    create_file "db/migrate/#{self.class.next_migration_number}_add_node_id_to_#{plural_name}.rb", <<-FILE
class AddNodeIdTo#{plural_name.camelize} < ActiveRecord::Migration
  def change
    add_column :#{plural_name}, :node_id, :integer
  end
end
		FILE
		rake "db:migrate"
	end
end