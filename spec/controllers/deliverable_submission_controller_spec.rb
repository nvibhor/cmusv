require 'spec_helper'

describe DeliverableSubmissionsController do 
  fixtures :users  
  integrate_views


  describe "NEW deliverable_submission" do

    before(:each) do
      todd = Factory.create(:staff)
      metrics = Factory.create(:metrics)
      team = Factory.create(:team, :primary_faculty_id => todd.id, :course_id => metrics.id)
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

  describe "authenticated downloads" do
    before(:each) do
      activate_authlogic
      UserSession.create users(:student_sam)
      @sam_deliverable = Factory(:deliverable_submission, :person_id => users(:student_sam).id)
      @becky_deliverable = Factory(:deliverable_submission, :person_id => users(:student_becky).id)
    end
    # TODO determine how to test this
    it "should not allow an non-authorized user to download the file" do
      get :index
      response.should be_success
      assert assigns(:deliverable_submissions).size == 1
    end

    # TODO determine how to test this
    it "should allow an authorized user to download the file" 
  end
end
