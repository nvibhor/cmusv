class AddIsIndividualColumnToDeliverableSubmission < ActiveRecord::Migration
  def self.up
    add_column :deliverable_submissions, :is_individual, :boolean, :default => false
  end

  def self.down
    remove_column :deliverable_submissions, :is_individual
  end

end
