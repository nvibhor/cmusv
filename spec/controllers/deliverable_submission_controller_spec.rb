require 'spec_helper'

describe DeliverableSubmissionsController do 
  fixtures :users  
  integrate_views


  describe "NEW deliverable_submission" do

    before(:each) do
      todd = Factory.create(:staff)
      architecture = Factory.create(:architecture)
      team = Factory.create(:team, :primary_faculty_id => todd.id, :course_id => architecture.id)
    end

    it "must have an individual checkbox" do
      activate_authlogic
      UserSession.create users(:student_sam)
      get :new
      response.should be_success
      response.should have_tag("input", :type => "checkbox")
    end
  end


  describe "authenticated EDIT deliverable_submission" do

    before(:each) do
      activate_authlogic
      UserSession.create users(:student_sam)
      @sam_deliverable = Factory(:deliverable_submission, :person_id => users(:student_sam).id)
      @becky_deliverable = Factory(:deliverable_submission, :person_id => users(:student_becky).id)
    end
    

    it "must have an individual checkbox" do
      @sam_deliverable.should be_valid      
      get :edit, :id => @sam_deliverable
      response.should be_success
      response.should have_tag("input", :type => "checkbox")
    end

    it "must fail if user does not own individual deliverable" do
      @becky_deliverable.should be_valid
      get :edit, :id => @becky_deliverable
      # TODO: hbarnor - Enable after teams support is in and controller code is enabled.
      # response.should_not be_success
      # response.should be_forbidden
    end

  end


end
