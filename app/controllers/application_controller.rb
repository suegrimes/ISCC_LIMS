# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include AuthenticatedSystem
  
  rescue_from CanCan::AccessDenied do |exception|
    user_login = (current_user.nil? ? nil : current_user.login)
    flash[:error] = "Sorry #{user_login} - requested page is invalid, or you are not authorized to access"
    redirect_to ''
  end
  
  require 'fastercsv'
  require 'calendar_date_select'

  #Login required for all controller actions
  before_filter :login_required
  
  #Make current_user accessible from model (via User.current_user)
  before_filter :set_current_user
  #before_filter :log_user_action
  #
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
protected
  def set_current_user
    @user = User.find_by_id(session[:user])
    if @user
      User.current_user = @user
    end
  end
  
  def log_user_action
    user_login = (User.current_user.nil? ? 'nil' : User.current_user.login)
    logger.info("<**User:  #{user_login} **> Controller/Action: #{self.controller_name}/#{self.action_name}" +
                  " IP: " + request.remote_ip + " Date/Time: " + Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    #UserLog.add_entry(self, User.current_user, request.remote_ip)
  end
  
end
