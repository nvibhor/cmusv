class DeliverableSubmissionsController < ApplicationController
  before_filter :require_user, :except => [:show_by_twiki]

  layout 'cmu_sv'

  # GET /deliverable_submissions
  # GET /deliverable_submissions.xml
  def index
    @deliverable_submissions = DeliverableSubmission.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @deliverable_submissions }
    end
  end

  # GET /deliverable_submissions/1
  # GET /deliverable_submissions/1.xml
  def show
    @deliverable_submission = DeliverableSubmission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @deliverable_submission }
    end
  end

  # GET /deliverable_submissions/new
  # GET /deliverable_submissions/new.xml
  def new
    @deliverable_submission = DeliverableSubmission.new
    if params[:course_id]
      course_id = params[:course_id].to_param
      # Ensure that course_id supplied is valid.
      # TODO(vibhor): Test this
      if Course.exists?(course_id)
        @course = Course.find(course_id)
        # Do not accept task_number if course_id supplied is not valid.
        if (params[:task_number])
          @task_number = params[:task_number].to_param
        end
      end
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @deliverable_submission }
    end
  end

  # GET /deliverable_submissions/1/edit
  def edit
    @deliverable_submission = DeliverableSubmission.find(params[:id])
    # TODO: hbarnor - Enable after teams support is in 
    # if !@deliverable_submission.editable(current_user)          
    #   flash[:error] = 'You are unable to update effort logs from the past.'
    #   redirect_to(deliverable_submission_url) and return
    # end

  end

  # POST /deliverable_submissions
  # POST /deliverable_submissions.xml
  def create
    @deliverable_submission = DeliverableSubmission.new(params[:deliverable_submission])
    @deliverable_submission.submission_date = DateTime.now
    @deliverable_submission.person_id = current_user.id

    respond_to do |format|
      if @deliverable_submission.save
        flash[:notice] = 'DeliverableSubmission was successfully created.'
        format.html { redirect_to(@deliverable_submission) }
        format.xml  { render :xml => @deliverable_submission, :status => :created, :location => @deliverable_submission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @deliverable_submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /deliverable_submissions/1
  # PUT /deliverable_submissions/1.xml
  def update
    @deliverable_submission = DeliverableSubmission.find(params[:id])
    @deliverable_submission.submission_date = DateTime.now

    respond_to do |format|
      if @deliverable_submission.update_attributes(params[:deliverable_submission])
        flash[:notice] = 'DeliverableSubmission was successfully updated.'
        format.html { redirect_to(@deliverable_submission) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @deliverable_submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /deliverable_submissions/1
  # DELETE /deliverable_submissions/1.xml
  def destroy
    @deliverable_submission = DeliverableSubmission.find(params[:id])
    @deliverable_submission.destroy

    respond_to do |format|
      format.html { redirect_to(deliverable_submissions_url) }
      format.xml  { head :ok }
    end
  end
end
