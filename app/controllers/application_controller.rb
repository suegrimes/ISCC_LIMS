class ApplicationController < ActionController::Base
  protect_from_forgery
  
  include AuthenticatedSystem

  rescue_from CanCan::AccessDenied do |exception|
    user_login = (current_user.nil? ? nil : current_user.login)
    flash[:error] = "Sorry #{user_login} - requested page is invalid, or you are not authorized to access"
    redirect_to ''
  end
  
  require 'csv'
  require 'mime/types'
#  require 'calendar_date_select'

  #Login required for all controller actions
  before_filter :login_required
  
  #Make current_user accessible from model (via User.current_user)
  before_filter :set_current_user
  
  #Write user, controller/action and timestamp to log file
  before_filter :log_user_action
  
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
protected
  def set_current_user
    @user = User.find_by_id(session[:user_id])
    if @user
      User.current_user = @user
    end
  end
  
  def set_lab_conditions(tablenm)
    (User.current_user.has_admin_access? ? [] : ["{modelnm}.lab_id = ?", user.lab_id])
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
      next if (File.directory?(File.join(dir_path, fn)) || fn[0].chr == '.' || fn.match('.ml')) #ignore directories, or system files
      files_list.push(fn) if fn.match(pattern)
    end
    return files_list
  end
  
  def file_content_type(file_path)    
    if (File.directory?(file_path) || file_path[0].chr == '.')
      return nil
    else
      mime_types = MIME::Types.type_for(file_path)
      return (mime_types.empty? ? 'text/plain' : MIME::Type.simplified(mime_types.first.to_s))
    end
  end
  
  def get_dir_list(dir_path, pattern='.')
    dirs_list = []
    if (File.directory?(dir_path))
      Dir.foreach(dir_path) do |fn|
        next if (fn == '.' || fn == '..') #ignore system files
        dirs_list.push(fn) if (File.directory?(File.join(dir_path, fn)) && fn.match(pattern))
      end
      return dirs_list
    else
      return []
    end
  end
  
  def html_imgs_to_base64(html_file, lab, dir)
    lines = File.open(html_file).readlines
      lines.each { |line|
        if line.match /<img/
          img_path = line.scan(/src=\"(.*\..*?)\"/).to_s
          rel_img_path = File.join(ResultFile::REL_PATH, lab, dir, img_path)
          img_type = line.scan(/src=\".*\.(.*?)\"/).to_s            
          base64_img = ActiveSupport::Base64.encode64(open(rel_img_path).to_a.join)            
          line.gsub!(/src=\".*?\"/, 'src="data:image/' + img_type + ';base64,' + base64_img + '"')          
        end          
      }
    File.open(html_file, 'w') { |f| f.write lines }
  end
  
  def html_imgs_change_path(html_file, html_file_cc, lab, dir)
    file = File.open(html_file, 'r')
    output = File.open(html_file_cc, 'w')
    while line = (file.gets)
      if line.match /<img/
        img_sub_dir = line.scan(/src=\"(.*?\/)/).to_s
        images_lab_fastqc_dir = File.join('"/images/', lab, '/', dir, '/', img_sub_dir)
        line.gsub!(/src=\".*?\//, 'src=' + images_lab_fastqc_dir)     
      end 
      output.write line
    end
    output.close
  end

  def sql_where(condition_array)
    # Handle change from Rails 2.3 to Rails 3.2 to turn conditions into individual parameters vs array
    if condition_array.nil? || condition_array.empty?
      return nil
    else
      return *condition_array
    end
  end
  
end
