Factory.define :time_entry do |f|
  f.hours 7.5
  f.notes 'Did some work'
  f.date Date.today
  f.association :activity
  f.association :hour_type
  f.association :user
end

Factory.define :hour_type do |f|
  f.name 'Normal'
end

Factory.define :customer do |f|
  f.name { Factory.next(:customer_name) }
  f.billable true
end

Factory.define :project do |f|
  f.name 'TimeFlux'
  f.users { |users| [users.association(:user)] }
  f.association :customer
end

Factory.define :activity do |f|
  f.name 'Development'
  f.association :project
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