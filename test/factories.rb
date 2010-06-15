Factory.define :billable_time_entry, :class => TimeEntry do |f|
  f.hours 7.5
  f.notes 'Did some work'
  f.date Date.today
  f.status TimeEntry::OPEN
  f.association :activity, :factory => :billable_activity
  f.association :hour_type
  f.association :user
end

Factory.define :unbillable_time_entry, :class => TimeEntry do |f|
  f.hours 7.5
  f.notes 'Did some work'
  f.date Date.today
  f.status TimeEntry::OPEN
  f.association :activity, :factory => :unbillable_activity
  f.association :hour_type
  f.association :user
end

Factory.define :hour_type do |f|
  f.name 'Normal'
end

Factory.define :billable_customer, :class => Customer do |f|
  f.name { Factory.next(:customer_name) }
  f.billable true
end

Factory.define :unbillable_customer, :class => Customer do |f|
  f.name { Factory.next(:customer_name) }
  f.billable false
end

Factory.define :billable_project, :class => Project do |f|
  f.name 'TimeFlux'
  f.users { |users| [users.association(:user)] }
  f.association :customer, :factory => :billable_customer
end 

Factory.define :unbillable_project, :class => Project do |f|
  f.name 'TimeFlux'
  f.users { |users| [users.association(:user)] }
  f.association :customer, :factory => :unbillable_customer
end

Factory.define :billable_activity, :class => Activity do |f|
  f.name 'Development'
  f.association :project, :factory => :billable_project
end

Factory.define :unbillable_activity, :class => Activity do |f|
  f.name 'Development'
  f.association :project, :factory => :unbillable_project
end

Factory.define :user do |f|
  f.firstname 'Fred'
  f.lastname 'Olsen'
  f.login { Factory.next(:login) }
  f.email { Factory.next(:email) }
  f.password 'secret'
  f.password_confirmation 'secret'
  #f.projects { |projects| [projects.association(:project)] }
end 

Factory.sequence :customer_name do |n|
  "ACME #{n}"
end

Factory.sequence :email do |n|
  "name#{n}@internet.com"
end

Factory.sequence :login do |n|
  "login#{n}"
end