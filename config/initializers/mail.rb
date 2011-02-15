#config/initializers/mail.rb

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
             :enable_starttls_auto => true,
             :address => 'smtp.stanford.edu',
             :port    => 25,
             :domain  => 'stanford.edu',
             :tls     => true}
#             :authentication => :login,
#             :user_name => 'sgrimes',
#             :password  => '[mypswd]'