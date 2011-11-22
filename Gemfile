source :gemcutter
source "http://gems.github.com"

gem "rake", "0.9.2.2"
gem "rails", "~> 2.3.8"
gem "sqlite3-ruby", "1.3.3", :require => "sqlite3"
gem "searchlogic"
gem "authlogic", "2.1.6"
gem 'will_paginate', '2.3.16', :require => 'will_paginate'  
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
  gem 'thoughtbot-shoulda', '2.10.2',      :require => 'shoulda'
  gem 'mocha', :require => false
end
