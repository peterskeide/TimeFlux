source :gemcutter
source "http://gems.github.com"

gem "rails", "~> 2.3.8"
#gem "sqlite3-ruby", :require => "sqlite3"

# bundler requires these gems in all environments
# gem "nokogiri", "1.4.2"
# gem "geokit"
gem "searchlogic"
gem "authlogic", "2.1.6"
  
gem 'mislav-will_paginate', "2.3.11", :require => 'will_paginate'
#  config.gem 'ruby-net-ldap', :require => 'net/ldap'
gem "prawn", "0.11.1"
gem 'prawn-core',      "0.5.1", :require => 'prawn/core'
gem 'prawn-format',    "0.2.1", :require => 'prawn/format'
gem 'prawn-layout',    "0.2.1", :require => 'prawn/layout'

group :development do
  # bundler requires these gems in development
  # gem "rails-footnotes"
end

group :test do
  # bundler requires these gems while running tests
  gem 'test-unit',               :require => 'test/unit'
  gem 'mocha'
  gem 'thoughtbot-shoulda', '2.10.2',      :require => 'shoulda'  
end
