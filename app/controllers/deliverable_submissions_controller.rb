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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @deliverable_submission }
    end
  end

  # GET /deliverable_submissions/1/edit
  def edit
    @deliverable_submission = DeliverableSubmission.find(params[:id])
  end

  # POST /deliverable_submissions
  # POST /deliverable_submissions.xml
  def create
    @deliverable_submission = DeliverableSubmission.new(params[:deliverable_submission])
    @deliverable_submission.submission_date = DateTime.now
    @deliverable_submission.person_id = current_user.id

    respond_to do |format|
      if @deliverable_submission.save
        send_email
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
  def send_email()
    # construct message consisting of who submitted, their team, course id (name), task number
    teams = Team.find(:all, :order => "id", :conditions => ["course_id = ?", @deliverable_submission.course_id])

    team = Team.new
    
    # Go through teams and try to find which teams in this course has this person.
    teams.each do |t|
      if(t.people.find(:first,  :conditions => ["id = ?", @deliverable_submission.person_id] )!=nil)
        team = t
        break
      end
    end

    message = "Submitted By : " + @deliverable_submission.person.human_name + " from Team : " + team.name + "\n"
    message += "Course ID : " + @deliverable_submission.course.name + " Task # : " + @deliverable_submission.task_number.to_s
    message += "\nComments : " + @deliverable_submission.comments;

    faculty = User.find_by_id(team.primary_faculty_id)
    if(!faculty.nil?)
       toaddress = faculty.email
    else
      toaddress = "anthony.tang@west.cmu.edu"
    end

     GenericMailer.deliver_email(
       :to => toaddress,
       :subject => "Deliverable Submission",
       :message => message
      )
  end
end
