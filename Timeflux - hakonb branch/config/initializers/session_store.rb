# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Timeflux - hakonb branch_session',
  :secret      => '3d81352b940b0238e0cd126cf81fb5f278814d8fa99414a32e3012557d6e018b82e119392fa27d25254f4bc17b4460ba38dcf99e531db4685e93b43d539deff1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
