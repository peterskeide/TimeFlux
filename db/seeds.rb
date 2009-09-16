
User.create :admin => true, :firstname => 'Admin', :lastname => 'User', :login => 'admin', :email => 'admin@local.com', :password => 'admin',:password_confirmation => 'admin', :operative_status => 'active'
User.create :firstname => 'Normal', :lastname => 'User', :login => 'user', :email => 'user@local.com', :password => 'user',:password_confirmation => 'user', :operative_status => 'active'

c = Customer.create(:name => 'Internal')
c.projects << p = Project.create(:name => 'Off-time')
p.activities << Activity.new(:name => 'Vacation', :description => 'Do not delete, ever!',:default_activity => false)

c = Customer.create(:name => 'Customer 1')
c.projects << p = Project.create(:name => 'Project 1')
p.activities << Activity.new(:name => 'Development', :default_activity => true)
p.activities << Activity.new(:name => 'Meeting', :default_activity => true)

Holiday.create(:date => Date.parse('1992-12-24'), :note => 'Christmas eve', :repeat => true, :working_hours => 0.0)

HourType.create :name => "Normal", :default_hour_type => true
HourType.create :name => "Overtime 50%"
HourType.create :name => "Overtime 100%"

Activity.create(:template => true, :name => 'Meeting', :description => 'General meeting activity' )
Activity.create(:template => true, :name => 'Travel', :description => 'General travel activity' )

