# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key    => '_microblog_aggregator_session',
  :secret => '14cd0c92902cc82f5b525c58cc9d5af5138b8bca11fc7ac481e9475978e156b28736fa537ab2dc424b49ec62b210eaaf73ae6f0cad1de3bbaac5cfcb3f82895f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
