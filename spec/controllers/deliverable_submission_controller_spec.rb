require 'spec_helper'

describe DeliverableSubmissionsController do 
  integrate_views


  describe "NEW deliverable_submission" do

    it "must have an individual checkbox" do
      activate_authlogic
      UserSession.create(Factory.create(:student, :first_name => 'Sam'))
      get :new
      response.should be_success
      response.should have_tag("input", :type => "checkbox")
    end
  end


  describe "authenticated EDIT deliverable_submission" do

    before(:each) do
      activate_authlogic
      sam = Factory.create(:student, :first_name => 'Sam')
      becky = Factory.create(:student, :first_name => 'Becky')
      UserSession.create(sam)
      @sam_deliverable = Factory(:deliverable_submission, :person => sam, :is_individual => true)
      @becky_deliverable = Factory(:deliverable_submission, :person => becky)
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
      response.should redirect_to(deliverable_submissions_url)
      flash[:error].should == 'You are not authorized to edit this deliverable.' 
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
