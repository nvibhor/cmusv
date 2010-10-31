class CreateDeliverableSubmissions < ActiveRecord::Migration
  def self.up
    create_table :deliverable_submissions do |t|
      t.date :submission_date
      t.integer :person_id
      t.integer :course_id
      t.integer :task_number
      t.string :comments
      # TODO(vibhor): Figure out what this field is for since we already have course_id.
      # The field name conflicts with belongs_to :course
      # t.string :course
      t.string :deliverable_file_name
      t.string :deliverable_content_type
      t.integer :deliverable_file_size

      t.timestamps
    end
  end

  def self.down
    drop_table :deliverable_submissions
  end
end
