class DeliverableSubmission < ActiveRecord::Base
  belongs_to :person

  # TODO(vibhor): The person will eventually be the signed in user.
  validates_presence_of :person
  validates_presence_of :submission_date

  has_attached_file :deliverable,
                    :path => ":rails_root/public/:class/:attachment/:id/:basename.:extension"

  validates_attachment_presence :deliverable
end
