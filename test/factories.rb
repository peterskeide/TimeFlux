Factory.define :time_entry do |f|
  f.hours 7.5
  f.notes 'Did some work'
  f.date Date.today
  f.association :project
  f.association :hour_type
  f.association :user
end

Factory.define :hour_type do |f|
  f.name 'Normal'
end

Factory.define :project do |f|
  f.name 'TimeFlux'
  f.users { |users| [users.association(:user)] }
end

Factory.define :activity do |f|
  f.name 'Development'
  f.association :project
end

Factory.define :user do |f|
  f.firstname 'Fred'
  f.lastname 'Olsen'
  f.login 'fredo'
  f.email 'fredo@timeflux.com'
  f.password 'secret'
  f.password_confirmation 'secret'
  f.projects { |projects| [projects.association(:project)] }
end

Factory.define :admin, :class => User do |f|
  f.firstname 'Bob'
  f.lastname 'Smith'
  f.login 'bobs'
  f.email 'bob@timeflux.com'
  f.password 'admin'
  f.password_confirmation 'admin'
  f.admin true
end