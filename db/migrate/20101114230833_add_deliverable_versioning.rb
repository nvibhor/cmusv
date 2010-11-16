class AddDeliverableVersioning < ActiveRecord::Migration
  def self.up
    DeliverableSubmission.create_versioned_table
  end

  def self.down
    DeliverableSubmission.drop_versioned_table
  end
end
