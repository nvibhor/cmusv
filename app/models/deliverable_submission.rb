class DeliverableSubmission < ActiveRecord::Base
  belongs_to :person
  belongs_to :course

  # TODO(vibhor): The person will eventually be the signed in user.
  validates_presence_of :person
  validates_presence_of :submission_date
  validates_associated :person

  # TODO(vibhor): Update to use amazon s3 as storage.
  has_attached_file :deliverable,
                    :storage => :filesystem,
                    :url => "/deliverable_submissions/:id/:filename",
                    :path => ":rails_root/public/deliverable_submissions/:id/:filename"

  validates_attachment_presence :deliverable
end
