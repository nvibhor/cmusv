require 'test_helper'
require 'mocha'
require 'gappsprovisioning/provisioningapi'
include GAppsProvisioning

class TeamTest < ActiveSupport::TestCase

  # NOTE:
  #  when testing Google Apps:
  #  1: do a .save when before minipulating fixtures
  #  2: do a .destroy on all objects that were saved

  def test_build_email
    domain = GOOGLE_DOMAIN
    course = Course.find(:first)
    record = Team.new(:name => 'RailsFixture Team A', :course_id => course.id)
    assert_equal(record.build_email, "fall-#{course.year}-railsfixture-team-a" + "@" + domain)
  rescue GDataError => e
    Rails.logger.debug("Skipping parts of this test case")
  end


  def test_google_apps_create_new_and_destroy
    #Clean up from a previous execution of a failed run of this test case
    google_apps_connection.delete_group("fall-2008-railsfixture-team-a")
  rescue GDataError => e

    course = Course.find(:first)
    record = nil
    assert_difference 'count_teams', 1 do
      assert_difference 'Team.count', 1 do
        record = Team.new(:name => 'RailsFixture Team A', :course_id => course.id)
        record.save
        #This next line is necessary since send_later delays -- maybe should be tested separately
        record.update_google_mailing_list(record.email, "nonexistant-email",  record.id)
      end
      wait_for_google_sync
    end
    assert_difference 'count_teams', -1 do
      assert_difference 'Team.count', -1 do
        record.destroy
      end
      wait_for_google_sync
    end
  rescue GDataError => e
    Rails.logger.debug("Skipping parts of this test case")
  end

#  ActiveRecord::MissingAttributeError: missing attribute: email on line 19 caused bye !new_team.save
#  def test_cannot_be_same_name
#    original_team = teams(:teamOne)
#    original_team.save
#
#    assert_no_difference 'count_teams' do
#      assert_no_difference 'Team.count' do
#        #clone original_team
#        new_team = Team.new
##        original_team.attributes.each {|attr, value| eval("new_team.#{attr}= original_team.#{attr}")}
#        new_team.email = original_team.email
#        assert !new_team.save, "Should not be able to save cloned team"
#      end
#      wait_for_google_sync
#    end
#    original_team.destroy
#    wait_for_google_sync
#  end


  def test_rename_team
    #Clean up from a previous execuction of a failed run of this test case
    old_group = "fall-2008-fixturedeming-teamone"
    renamed_group = "fall-2008-fixturedeming-teamone_renamed"
    google_apps_connection.retrieve_all_groups.each do |list|
      group_name = list.group_id.split('@')[0]
      google_apps_connection.delete_group(old_group) if old_group == group_name
      google_apps_connection.delete_group(renamed_group) if renamed_group == group_name
    end

    team = teams(:teamOne)
    team.save
    assert_no_difference 'count_teams', 0 do
      assert_no_difference 'Team.count', 0 do
        team.update_attributes({:name => "#{team.name}_renamed"})
      end
      wait_for_google_sync
    end
    team.destroy
    wait_for_google_sync
  rescue GDataError => e
    Rails.logger.debug("Skipping parts of this test case")
  end

  def test_proper_email
    course = Course.find(:first)
    record = Team.new(:name => 'RailsFixture Deming Team A', :course_id => course.id)
    record.save
    expected_email = "#{course.semester}-#{course.year}-#{record.name}@#{GOOGLE_DOMAIN}".chomp.downcase.gsub(/ /, '-')
    assert_equal record.email, expected_email, "Unexpected email value"
    record.destroy
    wait_for_google_sync
  rescue GDataError => e
    Rails.logger.debug("Skipping parts of this test case")
  end

  def test_change_mailinglist
    team = Team.find(:first)
    team.save
    #This next line is necessary since send_later delays
    team.update_google_mailing_list(team.email, "nonexistant-email@sandbox.sv.cmu.edu",  team.id)
    student = users(:student_sam)
    assert_not_nil team, "team should not be nil"
    assert_not_nil student, "student should not be nil"
    #puts "DEBUG: #{team.name} consists of #{count_members(team.build_email)} members"
    # add member
    assert_difference 'count_members(team.build_email)', 1 do
      team.add_person_by_human_name(student.human_name)
      team.save
      #This next line is necessary since send_later delays
      team.update_google_mailing_list(team.email, team.email,  team.id)
      
      wait_for_google_sync
      #puts "DEBUG: #{team.name} consistes of #{count_members(team.build_email)} members"
    end
    # remove member
    assert_difference 'count_members(team.build_email)', -1 do
      team.remove_person(student.id)
      wait_for_google_sync
      #puts "DEBUG: #{team.name} consistes of #{count_members(team.build_email)} members"
    end
    #puts "DEBUG: handle bad name"
    # handle bad name
    assert_no_difference 'team.people.count' do
      team.add_person_by_human_name("abc defg")
    end
    team.destroy
    wait_for_google_sync
  rescue GDataError => e
    Rails.logger.debug("Skipping parts of this test case")
  end



  # replace this with your real tests.
  def test_truth
    assert true
  end

  def test_creating_course_and_team_relationship
    course = Course.create
    team = course.teams.create

    # an id is assigned when they are committed to the database.
    assert_equal course.id, team.course.id
    assert_equal team.id, course.teams.find(:one).id

    assert_equal 1, course.teams.all.length, "course contains more teams than it should."
  end

  def test_deleting_team_removes_from_course
    course = Course.create
    team = course.teams.create

    team_id = team.id

    team.destroy

    assert_equal 0, course.teams.all.length, "destroying the team did not update the course."

    assert_raises activerecord::recordnotfound do
      team.find(team_id)
    end
  end

  def test_deleting_course_should_delete_linked_team
    course = Course.create
    team = course.teams.create

    team_id = team.id

    course.destroy

    assert_raises activerecord::recordnotfound do
      team.find(team_id)
    end
  end

  def test_team_belongs_to_primary_faculty
    team = teams(:one)
    team.primary_faculty = users(:faculty_frank)
    team.save
    assert_equal users(:faculty_frank).id, team.primary_faculty.id
  end

  def test_team_belongs_to_secondary_faculty
    team = teams(:one)
    team.secondary_faculty = users(:faculty_frank)
    team.save
    assert_equal users(:faculty_frank).id, team.secondary_faculty.id
  end

  def test_team_contains_multiple_students
    team = teams(:one)
    sam = users(:student_sam)
    sal = users(:student_sal)

    team.add_person_to_team(sam.human_name)
    team.add_person_to_team(sal.human_name)

    team_members = team.people.find(:all)

    team.save!

    team_members_hash = {}
    team_members.each do |member|
      team_members_hash[member.human_name] = member
    end

    assert_equal 2, team_members.length

    assert_not_nil team_members_hash["student_sam"], "sam should be a team member"
    assert_not_nil team_members_hash["student_sam"], "sal should be a team member"
  end


  def test_team_email_uniqueness_enforced
    course = Course.create
    team1 = course.teams.create
    team2 = course.teams.create

    team1.email = "address@host.com"
    team1.save!
    team2.email = "address@host.com"
    assert_raises (activerecord::missingattributeerror) do
      team2.save!
    end
  end

  def test_team_old_email_set_to_email_after_initialization
    course = Course.create
    team = course.teams.create
    team_id = team.id
    team.email = "address@host.com"
    team.save!
    assert_equal team.old_email, team.email
  end

  def test_team_strips_whitespace_from_name
    course = Course.create
    team = course.teams.create
    team.name = " hello "
    team.save!
    assert_equal "hello", team.name
  end

  def test_team_updates_email_from_west_to_sv_with_name
    course = Course.create
    team = course.teams.create
    team.name = "hello"
    team.email = "test@west.cmu.edu"
    team.save!
    assert_equal "test@sv.cmu.edu", team.email
  end

  def test_team_updates_email_from_west_to_sv_without_name
    course = Course.create
    team = course.teams.create
    team.email = "test@west.cmu.edu"
    team.save!
    assert_equal "test@sv.cmu.edu", team.email
  end

  def test_add_person_to_team
    course = Course.create
    team = course.teams.create
    sam = people(:student_sam)
    team.add_person_to_team(sam.human_name)
    team2 = team.find(team.id)
    assert team2.people.include?(sam)
  end

  def test_accessors_for_team_members
    course = Course.create
    team = course.teams.create
    team.person_name = people(:student_sam).human_name
    assert_equal team.person_name, people(:student_sam).human_name
    team.person_name2 = people(:student_sam).human_name
    assert_equal team.person_name2, people(:student_sam).human_name
    team.person_name3 = people(:student_sam).human_name
    assert_equal team.person_name3, people(:student_sam).human_name

  end

  def test_team_creation_without_name_or_email
    team = team.new(:course_id => courses(:one).id)
    assert !team.valid?
    assert_equal 'can\'t be blank', team.errors.on(:email)
  end

  def test_group_name_extraction
    course = Course.create
    team = course.teams.new(:email=>"test2@west.cmu.edu")
    assert_equal team.google_group, "test2"
  end

  def test_remove_person
    team = team.new(:id=>1)
    sam = people(:student_sam)
    team.add_person_to_team(sam.human_name)
    team.remove_person(sam.id)
    assert !team.people.include?(sam)
  end

  def test_remove_person_also_removes_from_google_group
    team = team.new(:id=>1)
    team.name = " hello"
    team.email = "test@sv.cmu.edu"
    dal = people(:student_dal)
    team.add_person_to_team(dal.human_name)

    provisioningapi.any_instance.expects(:remove_member_from_group).with(dal.email, team.google_group)
    team.remove_person(dal.id)
    assert !team.people.include?(dal)
  end

  def test_show_addresses_for_mailing_list
    team = team.new(:id=>1)
    team.name = " hello"
    team.email = "test@sv.cmu.edu"
    # assume that following are the members
    p1 = mock()
    p1.expects(:member_id).returns("p1@west.cmu.edu")
    p2 = mock()
    p2.expects(:member_id).returns("p2@sv.cmu.edu")
    provisioningapi.any_instance.expects(:retrieve_all_members).with(team.google_group).returns([p1, p2])
    members = team.show_addresses_for_mailing_list
    assert_equal members.length, 2
    assert_equal members[0], "p1@sv.cmu.edu"
    assert_equal members[1], "p2@sv.cmu.edu"
  end

  def test_empty_faculty_email_address
    team = team.new(:id=>1)
    faculty = team.faculty_email_addresses
    assert_equal faculty.length, 0
  end

  def test_faculty_email_address
    team = team.new(:id=>1)
    team.primary_faculty = users(:faculty_frank)
    team.secondary_faculty = users(:faculty_frank)
    faculty = team.faculty_email_addresses
    assert_equal faculty.length, 2
    assert_equal faculty[0], "frank@sv.cmu.edu"
  end

  def test_update_google_mailing_list_with_only_old_group_exists
    course = Course.create
    course.name = 'coursename'
    team = course.teams.create
    team.name = "hello"
    team.add_person_to_team(people(:student_dal).human_name)
    team.email = "test@west.cmu.edu"
    old_group = mock()
    old_group_name = 'old_group@someemail.web'
    old_group.expects(:group_id).returns(old_group_name)
    provisioningapi.any_instance.expects(:retrieve_all_groups).returns([old_group])
    provisioningapi.any_instance.expects(:delete_group).with('old_group')
    provisioningapi.any_instance.expects(:create_group).with('new_group', instance_of(array))
    provisioningapi.any_instance.expects(:add_member_to_group).with('dal@sv.cmu.edu', 'new_group')

    team.update_google_mailing_list('new_group@someemail.web', 'old_group@someemail.web', 1)
    assert !team.updating_email? 
  end

  def test_add_person_by_human_name
    team = team.new(:id=>1)
    team.email = "test@west.cmu.edu"
    team.name = "hello"
    dal = people(:student_dal)
    provisioningapi.any_instance.expects(:add_member_to_group).with('dal@sv.cmu.edu', 'test')
    team.add_person_by_human_name(dal.human_name)
  end

  private
  def count_teams
    google_apps_connection.retrieve_all_groups.size
  end
  def count_members(team_email)
    Rails.logger.debug "count_members#{team_email}"
    google_apps_connection.retrieve_all_members(team_email).size
  end

end
