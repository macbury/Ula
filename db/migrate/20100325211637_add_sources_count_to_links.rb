class AddSourcesCountToLinks < ActiveRecord::Migration
  def self.up
    add_column :links, :sources_count, :integer
		remove_column :links, :rate
  end

  def self.down
    remove_column :links, :sources_count
  end
end
