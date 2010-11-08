require 'spec_helper'

describe DeliverableSubmission do


  before(:each) do
    todd = Factory.create(:staff)
    architecture = Factory.create(:architecture)
    # team = Factory.create(:team, :primary_faculty_id => todd.id, :course_id => architecture.id)
    team = Factory.create(:team)
  end


  it "is valid with valid attributes" do 
    submission = Factory(:deliverable_submission)
    submission.should be_valid
    submission.person.should be_valid
  end

  it "is valid when an individual deliverable without a team" do
    submission = Factory(:deliverable_submission)
    submission.team = nil
    submission.is_individual = true
    submission.should be_valid
  end

  it "is not valid when not an individual deliverable or a team deliverable" do
    submission = Factory(:deliverable_submission)
    submission.team = nil
    submission.should_not be_valid
  end

  it " is not valid without a submission date" do
    submission = Factory.build(:deliverable_submission)
    submission.submission_date = nil
    submission.should_not be_valid
  end

  it " is not valid without a submitter" do
    submission = Factory.build(:deliverable_submission, :person => nil)
    submission.should_not be_valid
  end

  it " is not valid without a course" do
    submission = Factory.build(:deliverable_submission)
    submission.course = nil
    submission.should_not be_valid
  end

  it " is not valid with an invalid submitter" do
    person = Factory.build(:person) # an unsaved person.
    submission = Factory.build(:deliverable_submission, :person => person)
    submission.should_not be_valid
  end


  it " is not valid without a file attachment" do
    submission = Factory.build(:deliverable_submission)
    submission.deliverable_file_name = nil
    submission.should_not be_valid
  end

  it " is not valid with an empty filename" do
    submission = Factory.build(:deliverable_submission)
    submission.deliverable_file_name = ""
    submission.should_not be_valid
  end


end
