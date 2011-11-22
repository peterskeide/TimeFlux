
config.gem "thoughtbot-shoulda", :lib => "shoulda", :source => "http://gems.github.com"

# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Test unit must be loaded before mocha/shoulda or you will get a const_missing (NameError)
# when running rake test tasks 
# ref: http://floehopper.lighthouseapp.com/projects/22289-mocha/tickets/50
config.gem 'test-unit',               :lib => 'test/unit'
config.gem 'mocha'
config.gem 'thoughtbot-shoulda',  :version => '2.10.2',      :lib => 'shoulda',      :source => "http://gems.github.com"
#config.gem "thoughtbot-factory_girl", :lib => "factory_girl", :source => "http://gems.github.com"
