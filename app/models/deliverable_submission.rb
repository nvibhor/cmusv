class DeliverableSubmission < ActiveRecord::Base
  belongs_to :person
  belongs_to :course
  belongs_to :team

  validates_presence_of :person
  validates_associated :person
  validates_presence_of :submission_date
  validates_presence_of :course

  # TODO(vibhor): Update to use amazon s3 as storage.
  has_attached_file :deliverable,
                    :storage => :filesystem,
                    :url => "/deliverable_submissions/:id/:filename",
                    :path => ":rails_root/public/deliverable_submissions/:id/:filename"

  validates_attachment_presence :deliverable

  def before_save
    if not self.is_individual?
      self.person.teams.each do |t|
        if (t.course == self.course)
          self.team = t
        end
      end
    end
  end
end
