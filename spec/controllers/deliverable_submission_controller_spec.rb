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
      @sam_deliverable = Factory(:deliverable_submission, :person_id => users(:student_sam).id)
    end

    it "should not allow an non-authorized user to download the file" do
      activate_authlogic
      @sam = UserSession.create users(:student_sam)
      controller.stub(:current_user).and_return(@sam)
      @sam_deliverable.should_receive(:is_accessible_by).with(@sam).and_return(false)
      DeliverableSubmission.should_receive(:find).with(@sam_deliverable.id.to_s).and_return(@sam_deliverable)
      get :download, :id => @sam_deliverable.id
      response.should be_redirect
    end

    it "should allow an authorized user to download the file" do
      activate_authlogic
      @sam = UserSession.create users(:student_sam)
      file_location = "deliverable_submissions/#{@sam_deliverable.id}/#{@sam_deliverable.deliverable_file_name}"
      doc = "hi"
      File.open(file_location, 'w') {|f| f.write(doc) }
      controller.stub(:current_user).and_return(@sam)
      DeliverableSubmission.should_receive(:find).with(@sam_deliverable.id.to_s).and_return(@sam_deliverable)
      @sam_deliverable.should_receive(:is_accessible_by).with(@sam).and_return(true)
      get :download, :id => @sam_deliverable.id
      response.should be_success
    end
  end
end
