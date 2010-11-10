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
        team = user_team_enrolled_in_course(course_id)
        if (not team.nil?)
          @deliverable_submission.course = Course.find(course_id)
          @deliverable_submission.team = team
          # Do not accept task_number if course_id supplied is not valid.
          if (params[:task_number])
            @deliverable_submission.task_number = params[:task_number].to_param
          end
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
        send_faculty_email
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

  private
  def user_team_enrolled_in_course(course_id)
    # NOTE(vibhor): is checking for current semester courses only relevant?
    Person.find(current_user.id).teams.each do |t|
      if (t.course == Course.find(course_id))
        return t
      end
    end
    return nil  
  end

  def send_faculty_email()
    # construct message consisting of who submitted, their team, course id (name), task number
    team = nil
    team = user_team_enrolled_in_course(@deliverable_submission.course_id)

    # Team should always exist
    if not team.nil?
      message = "Submitted By : " + @deliverable_submission.person.human_name + "\n"
      if not @deliverable_submission.is_individual?
        message += "From Team : " + team.name + "\n"
      end

      message += "Course ID : " + @deliverable_submission.course.name + " Task # : " + @deliverable_submission.task_number.to_s
      message += "\nComments : " + @deliverable_submission.comments;

      faculty = User.find_by_id(team.primary_faculty_id)

      # Faculty should never be nil, if somehow they are, then don't send message
      if !faculty.nil?
         toaddress = faculty.email

       GenericMailer.deliver_email(
         :to => toaddress,
         :subject => "Deliverable Submission",
         :message => message
        )
      end
    end
  end
end
