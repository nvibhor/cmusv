class AddIndividualDeliverableColumnToDeliverableSubmission < ActiveRecord::Migration
  def self.up
    add_column :deliverable_submissions, :individual_deliverable, :boolean, :default => false
  end

  def self.down
    remove_column :deliverable_submissions, :individual_deliverable
  end
end
