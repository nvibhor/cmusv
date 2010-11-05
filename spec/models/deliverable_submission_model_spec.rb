require 'spec_helper'

describe DeliverableSubmission do

  Factory.sequence :login do |n|
    "person#{n}"
  end

  Factory.define :person, :class => Person do |p|
    p.is_staff 0
    p.is_active 1
    p.image_uri "/images/mascot.jpg"
  end

  Factory.define :todd, :parent => :person do |p|
    p.persistence_token Time.now.to_f.to_s
    p.first_name "Todd"
    p.last_name "Sedano"
    p.human_name "Todd Sedano"
    p.email "todd.sedano@sv.cmu.edu"
    p.is_staff 1
  end

  todd = Factory.create(:todd)

  Factory.define :user do |u|
    u.login 'bobs'
    u.email {|a| "#{a.first_name}.#{a.last_name}@andrew.cmu.edu" }
    u.is_student true
    u.is_staff false
    u.is_teacher false
    u.is_admin false
    u.is_alumnus false
    u.first_name 'Student'
    u.last_name 'Baba'
    u.human_name {|a| "#{a.first_name} #{a.last_name}" }
    u.image_uri 'images/mascot.jpg'
    u.password 'testararar'
    u.password_confirmation 'testararar'
  end
  

  Factory.define :architecture, :class => Course do |c|
   c.name "Architecture"
   c.number "96-705"
   c.semester "Summer"
   c.mini "Both"
   c.year "2008"
  end

  architecture = Factory.create(:architecture)

  Factory.define :team, :class => Team do |t|
   t.name "Team"
   t.email "team@sv.cmu.edu"
  end

  team = Factory.create(:team, :primary_faculty_id => todd.id, :course_id => architecture.id)

  Factory.define :deliverable_submission do |d|
    d.submission_date Date.today
    d.association :person_id, :factory => :user
    d.deliverable_file_name 'task1.zip'
    d.course architecture
    d.team team
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
    submission = Factory.build(:deliverable_submission)
    submission.person_id = nil
    submission.should_not be_valid
  end

  it " is not valid without a course" do
    submission = Factory.build(:deliverable_submission)
    submission.course = nil
    submission.should_not be_valid
  end

  it " is not valid with an invalid submitter" do
    submission = Factory.build(:deliverable_submission)
    submission.person_id = User.last.id + 1
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
