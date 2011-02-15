class WelcomeController < ApplicationController
  skip_before_filter :log_user_action
  
  def index
    if logged_in?
      render :action => 'index'
    else
      redirect_to login_path
    end
  end

end
