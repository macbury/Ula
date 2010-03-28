class ChangeTransportIdLimit < ActiveRecord::Migration
  def self.up
		change_column :sources, :transport_id, :bigint
  end

  def self.down
  end
end
