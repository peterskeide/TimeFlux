#Conduct users

User.create :firstname => 'Daniel', :lastname => 'Skarpås', :login => 'daniels', :email => 'daniels@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Erik', :lastname => 'Johansson', :login => 'erikj', :email => 'erikj@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Eirik', :lastname => 'Meland', :login => 'eirikm', :email => 'eirikm@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Alf', :lastname => 'Sagen', :login => 'alfs', :email => 'alfs@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Jari', :lastname => 'Nystedt', :login => 'jarin', :email => 'jarin@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Ola Marius H.', :lastname => 'Sagli', :login => 'olas', :email => 'olas@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Lars', :lastname => 'Johansson', :login => 'larsj', :email => 'larsj@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Marit Synnøve', :lastname => 'Vaksvik', :login => 'maritva', :email => 'maritva@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Jonas', :lastname => 'Olsson', :login => 'jonaso', :email => 'jonaso@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Pål Oliver', :lastname => 'Kristiansen', :login => 'palok', :email => 'palok@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Bjørn Ola', :lastname => 'Smievoll', :login => 'bos', :email => 'bos@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Henrik', :lastname => 'Brautaset Aronsen', :login => 'hba', :email => 'hba@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Eirik Nicolai', :lastname => 'Synnes', :login => 'eirikns', :email => 'eirikns@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Jeppe A.B.', :lastname => 'Weinreich', :login => 'jeppe', :email => 'jeppe@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Daniel', :lastname => 'Engfeldt', :login => 'daniele', :email => 'daniele@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Aslak', :lastname => 'Knutsen', :login => 'aslak', :email => 'aslak@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Roall', :lastname => 'Lein-Killi', :login => 'killi', :email => 'killi@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Marius', :lastname => 'Sorteberg', :login => 'marius', :email => 'marius@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Jon', :lastname => 'Bråten', :login => 'jonb', :email => 'jonb@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Lars Preben', :lastname => 'Sørsdahl', :login => 'larsar', :email => 'larsar@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Thomas', :lastname => 'Roka-Aardal', :login => 'thomasa', :email => 'thomasa@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Ståle', :lastname => 'Tomten', :login => 'stalet', :email => 'stalet@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Pål', :lastname => 'Kirkebø', :login => 'paalk', :email => 'paalk@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :firstname => 'Martin', :lastname => 'Stangeland', :login => 'martins', :email => 'martins@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'

User.create :admin => true, :firstname => 'Håkon', :lastname => 'Bommen', :login => 'hakonb', :email => 'hakonb@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :admin => true, :firstname => 'Peter', :lastname => 'Skeide', :login => 'peters', :email => 'peters@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :admin => true, :firstname => 'Jon-Erik', :lastname => 'Trøften', :login => 'jet', :email => 'jet@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'
User.create :admin => true, :firstname => 'Eirik', :lastname => 'Valen', :login => 'erk', :email => 'erk@conduct.no', :password => 'secret',:password_confirmation => 'secret', :operative_status => 'active'


c = Customer.create(:name => 'Conduct')
c.projects << p = Project.create(:name => 'Fri')
p.activities << Activity.new(:name => 'Ferie', :description => 'Ikke slett meg!',:default_activity => true)

c.projects << Project.create(:name => 'Conduct Community Contribution Project')

Holiday.create(:date => Date.parse('1992-6-1'), :note => '1 Mai', :repeat => true, :working_hours => 0.0)
Holiday.create(:date => Date.parse('1992-6-17'), :note => '17 Mai', :repeat => true, :working_hours => 0.0)
Holiday.create(:date => Date.parse('1992-12-24'), :note => 'Juleaften', :repeat => true, :working_hours => 0.0)
Holiday.create(:date => Date.parse('1992-1-1'), :note => 'Første nyttårsdag', :repeat => true, :working_hours => 0.0)

HourType.create :name => "Normaltid", :default_hour_type => true
HourType.create :name => "Overtid 50%"
HourType.create :name => "Overtid 100%"

Activity.create(:template => true, :name => 'Reisevirksomhet', :description => 'Reiser til og fra kunde der det er avtalt med kunde at dette skal faktureres' )
Activity.create(:template => true, :name => 'Utvikling', :description => 'Generell utvikling' )
Activity.create(:template => true, :name => 'Møte', :description => 'Møtevirksomhet' )
