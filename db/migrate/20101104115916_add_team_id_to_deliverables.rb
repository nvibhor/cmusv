class AddTeamIdToDeliverables < ActiveRecord::Migration
  def self.up
    add_column :deliverable_submissions, :team_id, :integer
  end

  def self.down
    remove_column :deliverable_submissions, :team_id
  end
end
