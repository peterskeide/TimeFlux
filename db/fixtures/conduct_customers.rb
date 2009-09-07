

#SELECT "name" FROM "public"."timeflux_project" WHERE "parent_id" IS NULL

customer_names = '"Norwegian Air Shuttle"
"Oslo Børs"
"Selvaag Bluethink"
"Otrum"
"Expert"
"Zett"
"Conduct"
"FLO/IKT (Forsvaret)"
"NLS"
"Carrot"
"Statens Pensjonskasse"
"Fara"
"Sparebank 1 Skadeforsikring"
"Aftenposten"
"Hurtigruten ASA"
"Tomra"
"Hafslund Telekom"
"TraceTracker"
"USIT"
"Tollpost"
"Avinor"
"nytt prosjekt"
"Aspiro"
"Opplysningen"
"TV2"
"NSB"
"Umoe Consulting"
"A-pressen"
"ABMU"
"Nordpool"
"NMD"
"Norgesgruppen Data AS"
"NetTicket"
"FOSS community"
"EDB"
"FileFlow"
"Boostcom"
"Mercer HR"
"Ergo"
"Deichman"
"Nasjonalt Kompetansesenter for Helsetjenester"
"Mobiletech"
"Community Reborn"
"Message Management"
"Corporate Express Nordic AS"
"Flexistamp"
"Geodata AS"
"Agder Energi"
"Schibsted"
"Politiet"
"Simula"
"Skagerak"'

customer_names.split("\n").each  do |name|
  clean_name = name.gsub(/"/, '')
  Customer.create(:name => clean_name)
  puts "created customer: #{clean_name}"
end



