require 'spec_helper'

describe DeliverableSubmission do
  before(:each) do
    @todd = Factory.create(:staff)
    @architecture = Factory.create(:architecture)
    @team = Factory.create(:team)
  end

  it "adds a team for team deliverable after save" do
    course = Factory(:metrics)
    sam = Factory.create(:student, :first_name => 'Sam')
    becky = Factory.create(:student, :first_name => 'Becky')
    team = Factory(:team, :people => [sam, becky], :course => course)
    submission = Factory(:deliverable_submission, :is_individual => false, :course => course, :person => sam)
    assert_equal submission.team, team
  end

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
    person = Factory.build(:default_person) # an unsaved person.
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
  
  describe "determines access for" do
    before(:each) do
      @submission = Factory.create(:deliverable_submission_with_team)
      @submission.is_individual = false
      @submission.team = @team
      people = Person.find(:all, :conditions => {:is_student => true})
      @team_members = people.slice(0,4) - [@submission.person]
      @team.people = @team_members + [@submission.person]
    end

    it "a nil user (unauthorized)" do
      result = @submission.is_accessible_by(nil)
      assert_equal false, result, "Deliverable should not be accessible to a nil user"
    end

    it "an owner of an individual deliverable (authorized)" do
      @submission.is_individual = true
      @submission.team = nil
      result = @submission.is_accessible_by(@submission.person)
      assert_equal true, result, "Deliverable should be accessible to its owner"
    end

    it "an owner of a team deliverable (authorized)" do
      result = @submission.is_accessible_by(@submission.person)
    end

    it "a non-member of a team deliverable who is not the owner (unauthorized)" do
      team_members = @team.people - [@submission.person]
      unauthorized_user = team_members.pop
      @team.people = @team.people - [unauthorized_user]
      result = @submission.is_accessible_by(unauthorized_user)
      assert_equal false, result, "Deliverable should not be accessible to non-team members"
    end

    it "a member of a team deliverable who is not the owner (authorized)" do
      team_members = @team.people - [@submission.person]
      assert_not_nil team_members[0]
      result = @submission.is_accessible_by(team_members[0])
      assert_equal true, result, "Deliverable should be accessible to team members"
    end

    it "a staff member (authorized)" do
      @todd.is_student = false
      @todd.is_staff = true
      result = @submission.is_accessible_by(@todd)
      assert_equal true, result, "Deliverable should be accessible to faculty members"
    end
  end
end
