# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  
  skip_before_filter :login_required, :only => [:new, :create]

  #layout 'welcome'
  # render new.erb.html
  def new
    @labs = Lab.find(:all, :order => :lab_name)
  end

  def create
    logout_keeping_session!
    if !params[:lab][:id].blank?
      user = User.authenticate(params[:lab][:id], params[:login], params[:password])
      if user
        # Protects against session fixation attacks, causes request forgery
        # protection if user resubmits an earlier form using back
        # button. Uncomment if you understand the tradeoffs.
        # reset_session
        self.current_user = user
        new_cookie_flag = (params[:remember_me] == "1")
        handle_remember_cookie! new_cookie_flag
        flash[:notice] = "Logged in successfully"
        redirect_to :controller => :welcome, :action => :index
      else
        note_failed_signin
        @lab         = Lab.find(params[:lab][:id]) if !params[:lab][:id].blank?
        @login       = params[:login]
        @remember_me = params[:remember_me]
        @labs        = Lab.find(:all, :order => :lab_name)
        render :action => 'new'
      end
    else
      flash[:error] = "Lab must be entered - please try again"
      @login       = params[:login]
      @remember_me = params[:remember_me]
      @labs        = Lab.find(:all, :order => :lab_name)
      render :action => 'new'
    end
  end

  def destroy
    logout_killing_session!
    flash[:notice] = "You have been logged out."
    redirect_to :action => :new
  end

protected
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:login]}'"
    logger.warn "Failed login for '#{params[:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  
end
