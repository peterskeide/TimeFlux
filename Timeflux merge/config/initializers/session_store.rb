# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Timeflux merge_session',
  :secret      => 'f8e1df6364fda76074fa3ba44d614e028bc7ed1ab8ee0797f548a46b8585220f0b1ab5ccfb1fad5220d4efbf0d756af0df7bf5b7dae6435304b9d52f4fc379ae'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
