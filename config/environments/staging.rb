# Settings specified here will take precedence over those in config/environment.rb
SITE_URL = "localhost:3005"

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# Enable delivery error messages
config.action_mailer.raise_delivery_errors = true

# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

# Enable threaded mode
# config.threadsafe!