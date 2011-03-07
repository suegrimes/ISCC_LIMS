class UsersController < ApplicationController  
  skip_before_filter :login_required
  
  # render new.rhtml
  def new
    @user = User.new
    @labs = Lab.find(:all, :order => :lab_name)
  end
 
  def create
    logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    if success && @user.errors.empty?
      redirect_back_or_default('/')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact system admin"
      @labs = Lab.find(:all, :order => :lab_name)
      render :action => 'new'
    end
  end
  
  # render edit.html
  def edit 
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
          
    if @user.authenticated?(params[:curr_user][:current_password])
      if @user.update_attributes(params[:user])
        flash[:notice] = "User has been updated"
        redirect_to users_url
      else
        flash.now[:error] = "Error updating user"
        render :action => 'edit'
      end
      
    else
      flash.now[:error] = "Incorrect current password entered - please try again"
      render :action => 'edit'
    end
  end

  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_to '/login'
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_to '/login'
    end
  end
  
  def forgot
    if request.post?
      user = User.find_by_email(params[:user][:email])
      
      if user
        user.reset!
        flash[:notice] = "Reset code sent to #{user.email}"
        redirect_to login_path
      else
        flash[:error] = "#{params[:user][:email]} does not exist in system"
        redirect_to forgot_path
      end
    end
  end
  
  def reset
    @user = User.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    
    if request.post? # Processing reset of password
      if @user.update_attributes(:password => params[:user][:password],
                                 :password_confirmation => params[:user][:password_confirmation])
        self.current_user = @user
        @user.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@user.email}"
        redirect_to :controller => 'welcome', :action => 'index'
      else
        render :action => :reset # Error saving new password, should result in validation error message
      end
      
    else             # Requesting form for entry of new password
      if !@user.nil?
        render :action => :reset
      else
        flash[:error]  = "We couldn't find a user with that reset code -- check your email? Or maybe you've already reset -- try signing in."
        redirect_to '/login'
      end
    end
  end
  
end
