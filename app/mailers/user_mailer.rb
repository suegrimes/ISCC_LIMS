class UserMailer < ActionMailer::Base
  default content_type: 'text/html', from: 'iscc_noreply@stanford.edu'

  def signup_notification(user)
    @user = user
    @url = "http://#{SITE_URL}/activate/#{user.activation_code}"
    mail(:subject => 'ISCC RNASeq: Please activate your new account',
         :to => "#{user.email}")
  end

  def activation(user)
    @user = user
    @url = "http://#{SITE_URL}/"
    mail(:subject => 'ISCC RNASeq: Your account has been activated',
         :to => "#{user.email}")
  end
  
  def reset_notification(user)
    @user = user
    @url = "http://#{SITE_URL}/reset/#{user.reset_code}"
    mail(:subject => 'ISCC RNASeq: Link to reset your password',
         :to => "#{user.email}")
  end
end
