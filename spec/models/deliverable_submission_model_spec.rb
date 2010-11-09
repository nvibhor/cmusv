require 'spec_helper'

describe DeliverableSubmission do
# NOTE(vibhor): Can't get this test to pass because I am not able to setup a team people association using factories.
#  it "adds a team for team deliverable after save" do
#    submission = Factory(:deliverable_submission)
#    submission.is_individual = false
#    submission.team = nil
#    submission.course = Factory(:architecture)
#    submission.save!
#    assert submission.team.equals(team)
#  end

  it "is valid with valid attributes" do
    submission = Factory(:deliverable_submission)
    submission.should be_valid
    submission.person.should be_valid
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
