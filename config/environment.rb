# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')
 
Rails::Initializer.run do |config|

  config.gem 'authlogic',     :version => '2.1.5'
  config.gem 'will_paginate', :version => '2.3.14'
  config.gem 'ruby-net-ldap', :lib => 'net/ldap', :version => '0.0.4'
  config.gem 'prawn',         :version => '0.8.4'
  
  config.time_zone = 'UTC'

  config.action_controller.session = {
    :session_key => '_timeflux_session',
    :secret      => '42d98fd07a9b22a84ecc394d9391f9696b9cff52289f7bea3b2bd9f51e8865bcb96e634ec726c67e0e2334b6faaada0654df51fa6c5b848f5724384004a9c00b'
  }

end