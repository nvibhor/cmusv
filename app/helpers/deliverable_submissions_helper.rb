module DeliverableSubmissionsHelper
  def find_current_semester_teams
    puts Person.find(current_user.id).teams.name
    Person.find(current_user.id).find_teams_by_semester(Date.today.year, current_semester)
  end

end
