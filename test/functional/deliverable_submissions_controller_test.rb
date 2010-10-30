require 'test_helper'

class DeliverableSubmissionsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:deliverable_submissions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create deliverable_submission" do
    assert_difference('DeliverableSubmission.count') do
      post :create, :deliverable_submission => { }
    end

    assert_redirected_to deliverable_submission_path(assigns(:deliverable_submission))
  end

  test "should show deliverable_submission" do
    get :show, :id => deliverable_submissions(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => deliverable_submissions(:one).to_param
    assert_response :success
  end

  test "should update deliverable_submission" do
    put :update, :id => deliverable_submissions(:one).to_param, :deliverable_submission => { }
    assert_redirected_to deliverable_submission_path(assigns(:deliverable_submission))
  end

  test "should destroy deliverable_submission" do
    assert_difference('DeliverableSubmission.count', -1) do
      delete :destroy, :id => deliverable_submissions(:one).to_param
    end

    assert_redirected_to deliverable_submissions_path
  end
end
