class RemoveCourseFromDeliverableSubmission < ActiveRecord::Migration
  def self.up
    remove_column :deliverable_submissions, :course
  end

  def self.down
  end
end
