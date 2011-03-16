class AuthUsersController < ApplicationController
  load_and_authorize_resource
  
  before_filter :dropdowns, :only => [:new, :edit]
  
  # GET /auth_users
  # GET /auth_users.xml
  def index
    @auth_users = AuthUser.find(:all, :include => :lab)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @auth_users }
    end
  end

  # GET /auth_users/1
  # GET /auth_users/1.xml
  def show
    @auth_user = AuthUser.find(params[:id], :include => :lab)

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @auth_user }
    end
  end

  # GET /auth_users/new
  # GET /auth_users/new.xml
  def new
    @auth_user = AuthUser.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @auth_user }
    end
  end

  # GET /auth_users/1/edit
  def edit
    @auth_user = AuthUser.find(params[:id], :include => :user)
  end

  # POST /auth_users
  # POST /auth_users.xml
  def create
    @auth_user = AuthUser.new(params[:auth_user])

    respond_to do |format|
      if @auth_user.save
        flash[:notice] = 'Authorized user was successfully created.'
        format.html { redirect_to(@auth_user) }
        format.xml  { render :xml => @auth_user, :status => :created, :location => @auth_user }
      else
        dropdowns
        format.html { render :action => "new" }
        format.xml  { render :xml => @auth_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /auth_users/1
  # PUT /auth_users/1.xml
  def update
    @auth_user = AuthUser.find(params[:id])

    respond_to do |format|
      if @auth_user.update_attributes(params[:auth_user])
        flash[:notice] = 'Authorized user was successfully updated.'
        format.html { redirect_to(@auth_user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @auth_user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /auth_users/1
  # DELETE /auth_users/1.xml
  def destroy
    @auth_user = AuthUser.find(params[:id])
    @auth_user.destroy

    respond_to do |format|
      format.html { redirect_to(auth_users_url) }
      format.xml  { head :ok }
    end
  end
  
protected
  def dropdowns
    @labs = Lab.find(:all)
  end
end
