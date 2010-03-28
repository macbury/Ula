class RemoveTypeFromSources < ActiveRecord::Migration
  def self.up
		remove_column :sources, :type
		add_column :sources, :transport, :string
		add_column :sources, :transport_id, :integer
  end

  def self.down
  end
end
