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
                    :url => "/deliverable_submissions/download/:id",
                    :path => ":rails_root/deliverable_submissions/:id/:filename"

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

  def is_accessible_by(user)
    access = false
    if not user.nil?
      # owner
      if self.person.id == user.id
        access = true
      end

      # faculty member
      if user.is_staff == true
        access = true
      end

      # team member in team deliverable
      if self.is_individual == false
        if not self.team.nil?
          if self.team.people.include?(user)
            access = true
          end
        end
      end
    end
    access
  end
end
