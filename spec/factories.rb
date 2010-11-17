
Factory.define :default_person, :class => Person do |p|
  p.is_teacher false
  p.is_admin false
  p.is_alumnus false
  p.password 'secret'
  p.human_name {|a| "#{a.first_name} #{a.last_name}" }
end

Factory.define :staff, :parent => :default_person do |p|
  p.persistence_token Time.now.to_f.to_s
  p.login "toddf"
  p.first_name "Todd"
  p.last_name "Staff"
  p.human_name "Todd Staff"
  p.email "todd.staffy@sv.cmu.edu"
  p.is_staff 1
end

Factory.define :student, :parent => :default_person do |u|
  u.sequence(:login) { |n| "student#{n}" }
  u.first_name 'Baba'
  u.last_name 'Student'
  u.email {|a| "#{a.first_name}.#{a.last_name}@andrew.cmu.edu" }
  u.is_student true
end

Factory.define :course, :class => Course do |c|
  c.name 'Course'
  c.semester ApplicationController.current_semester
  c.year  Date.today.year
  c.mini 'Both'
end

Factory.define :metrics, :parent => :course do |c|
  c.name "Metrics"
  c.number "96-705"
end

Factory.define :team, :class => Team do |t|
  t.sequence(:name) { |x|  "Team #{x}" }
  t.association :course, :factory => :metrics
end

Factory.define :deliverable_submission do |d|
  d.submission_date Date.today
  d.association :person, :factory => :student
  d.sequence(:deliverable_file_name) { |n|  "task#{n}.zip" }
  d.association :course
end

Factory.define :deliverable_submission_with_team, :parent => :deliverable_submission do |d|
  d.association :team
end