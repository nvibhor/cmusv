class DeliverableSubmission < ActiveRecord::Base
  belongs_to :person
  belongs_to :course
  belongs_to :team

  validates_presence_of :person
  validates_presence_of :submission_date
  validates_associated :person
  # This validation is not entirely true as there can be individual deliverable submissions.
  # TODO(vibhor): Fix this once we bring in the notion of individual deliverable.
  validates_presence_of :team

  # TODO(vibhor): Update to use amazon s3 as storage.
  has_attached_file :deliverable,
                    :storage => :filesystem,
                    :url => "/deliverable_submissions/:id/:filename",
                    :path => ":rails_root/public/deliverable_submissions/:id/:filename"

  validates_attachment_presence :deliverable
end
