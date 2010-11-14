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
                    :url => "/deliverable_submissions/download/:filename",
                    :path => ":rails_root/public/deliverable_submissions/:id/:filename"

  validates_attachment_presence :deliverable

  def before_save
    if not self.is_individual?
      self.course.teams.each do |t|
        if t.people.include?(self.person)
          self.team = t
        end
      end
    end
  end

  # editable wrapper
  def editable?(current_user)
    is_accessible_by(current_user)
  end


  def is_accessible_by(user)
    # could not find a clear example of overriding the 
    # the comparison operator in models 
    # so for now we do this hack     
    if user.instance_of?(User)
      # $stdout.sync = true
      user = Person.find(user.id)
    end
    access = false
    if not user.nil?
      # owner
      if self.person == user
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
