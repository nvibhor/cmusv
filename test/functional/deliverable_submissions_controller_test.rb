require 'test_helper'

class DeliverableSubmissionsControllerTest < ActionController::TestCase
  test "should_redirect_without_logged_in" do
    get :index
    assert_redirected_to login_google_url
  end

  test "should get index" do
    login_as :student_sam
    get :index
    assert_response :success
    assert_not_nil assigns(:deliverable_submissions)
  end

  test "should get new" do
    login_as :student_sam
    get :new
    assert_response :success
  end

  test "should create deliverable_submission" do
    login_as :student_sam
    assert_difference('DeliverableSubmission.count') do
      post :create, :deliverable_submission => {:deliverable_file_name => 'task1.zip',
                                                :course_id => courses(:mfse).id,
                                                :is_individual => true}
    end

    assert_redirected_to deliverable_submission_path(assigns(:deliverable_submission))
  end

  test "should show deliverable_submission" do
    login_as :student_sam    
    get :show, :id => deliverable_submissions(:one).to_param
    assert_redirected_to(deliverable_submissions_url)
  end

  test "should get edit" do
    login_as :student_sam
    get :edit, :id => deliverable_submissions(:one).to_param
    assert_redirected_to(deliverable_submissions_url)
  end

  test "should update deliverable_submission" do
    login_as :student_sam
    put :update, :id => deliverable_submissions(:one).to_param,
         :deliverable_submission => {:deliverable_file_name => 'task1.zip',
                                     :course_id => courses(:mfse).id,
                                     :is_individual => true}
    assert_redirected_to deliverable_submission_path(assigns(:deliverable_submission))
  end

  test "should destroy deliverable_submission" do
    login_as :student_sam
    assert_difference('DeliverableSubmission.count', -1) do
      delete :destroy, :id => deliverable_submissions(:one).to_param
    end

    assert_redirected_to deliverable_submissions_path
  end
end
