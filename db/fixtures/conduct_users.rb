
#From existing timeflux: SELECT "firstname","lastname","username" FROM "public"."timeflux_person"

users = '"Daniel","Skarpås","daniels","daniels@conduct.no"
"Erik","Johansson","erikj",nil
"Eirik","Meland","eirikm",nil
"Alf","Sagen","alfs","alfs@conduct.no"
"Jari","Nystedt","jarin",nil
"Ola Marius H.","Sagli","olas","olas@conduct.no"
"Peter","Skeide","peters","peters@conduct.no"
"Lars","Johansson","larsj","larsj@conduct.no"
"Hans Lõwe","Larsen","hansl",nil
"Jon-Erik","Trøften","jet","jet@conduct.no"
"Marit Synnøve","Vaksvik","maritva","maritva@conduct.no"
"Jonas","Olsson","jonaso","jonaso@conduct.no"
"Pål Oliver","Kristiansen","palok",nil
"Bjørn Ola","Smievoll","bos","bos@conduct.no"
"Henrik","Brautaset Aronsen","hba",nil
"Eirik Nicolai","Synnes","eirikns","eirikns@conduct.no"
"Jeppe A.B.","Weinreich","jeppe","jeppe@conduct.no"
"Daniel","Engfeldt","daniele","daniele@conduct.no"
"Aslak","Knutsen","aslak",nil
"Eirik","Valen","erk",nil
"Roall","Lein-Killi","killi",nil
"Marius","Sorteberg","marius","marius@conduct.no"
"Jon","Bråten","jonb","jonb@conduct.no"
"Lars Preben","Sørsdahl","larsar","larsar@conduct.no"
"Thomas","Roka-Aardal","thomasa","thomasa@conduct.no"
"Ståle","Tomten","stalet","stalet@conduct.no"
"Pål","Kirkebø","paalk","paalk@conduct.no"
"Martin","Stangeland","martins","martins@conduct.no"
"Håkon","Bommen","hakonb","hakonb@conduct.no"'

users.split("\n").each  do |name|
  entry = name.split(",")
  firstname = entry[0].gsub(/"/, '')
  lastname = entry[1].gsub(/"/, '')
  username = entry[2].gsub(/"/, '')

  user = User.create( :firstname => firstname, :lastname => lastname , :login => username, :email => "#{username}@conduct.no",
    :password => "secret",:password_confirmation => "secret", :operative_status => 'active' )

  puts "User created: #{user.name}"
end
      
       
