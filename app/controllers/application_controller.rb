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
  
  #Write user, controller/action and timestamp to log file
  before_filter :log_user_action
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password
  
protected
  def set_current_user
    @user = User.find_by_id(session[:user_id])
    if @user
      User.current_user = @user
    end
  end
  
  def set_lab_conditions(tablenm)
    (current_user.has_admin_access? ? [] : ["{modelnm}.lab_id = ?", user.lab_id])
  end
  
  def log_user_action
    user_login = (User.current_user.nil? ? 'nil' : User.current_user.login)
    logger.info("<**User:  #{user_login} **> Controller/Action: #{self.controller_name}/#{self.action_name}" +
                  " IP: " + request.remote_ip + " Date/Time: " + Time.now.strftime("%Y-%m-%d %H:%M:%S"))
    UserLog.add_entry(self, User.current_user, request.remote_ip)
  end
  
  def get_file_list(dir_path, pattern='.')
    files_list = []
    Dir.foreach(dir_path) do |fn|
      next if (File.directory?(File.join(dir_path, fn)) || fn[0].chr == '.') #ignore directories, or system files
      files_list.push(fn) if fn.match(pattern)
    end
    return files_list
  end
  
  def file_content_type(file_path)    
    if (File.directory?(file_path) || file_path[0].chr == '.')
      return nil
    else
      extname = File.extname(file_path)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(extname)
      content_type = mime_type.to_s unless mime_type.nil?
      
      return ((mime_type.nil? || mime_type == 'zip') ? nil : content_type)
    end
  end
  
  def get_dir_list(dir_path, pattern='.')
    dirs_list = []
    Dir.foreach(dir_path) do |fn|
      next if (fn == '.' || fn == '..') #ignore system files
      dirs_list.push(fn) if (File.directory?(File.join(dir_path, fn)) && fn.match(pattern))
    end
    return dirs_list
  end
  
end
