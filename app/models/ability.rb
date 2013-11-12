# Authorization rules, using authorization gem: "cancan"
# Add the following code in all controllers for which authorization should apply:
#   load_and_authorize_resource

# Any common non-RESTful actions across controllers can be mapped to a standard action such 
# as 'read' using 'alias_action', below.
# Alternatively, can restrict access within a specific controller method with:
#   authorize! :action, model_object

# In views, to test whether the current user has permissions to perform a given 'action' on a
# specific 'model_object', use: 
#    if can? :action, model_object

# rescue clause for unauthorized actions, is in application controller.

class Ability
  include CanCan::Ability
  
  def initialize(user=current_user)
    
    # Everyone can create a new user, or view/edit their own user information
    can [:new, :create, :forgot, :reset], User
    can [:show, :edit, :update], User do |usr|  # cannot use :manage, with do block
        usr.login == user.login
    end
    
    # Everyone can manage samples & shipments for their own lab only
    can [:new, :create, :index, :show, :show_sop], Sample
    can [:edit, :update, :shipment_confirm, :sample_ship, :delete], Sample do |sample|
      sample.lab_id == user.lab_id
    end
    
    can [:new, :create, :index], Shipment
    can [:show, :edit, :update, :delete], Shipment do |shipment|
      shipment.sample.lab_id == user.lab_id
    end
    
    # Everyone can view result_files for their own lab only (access to index view managed in controller)
    can [:index, :show_rdef], ResultFile
    can [:show, :fastqc_show, :download], ResultFile do |result_file|
      result_file.lab_id == user.lab_id
    end
    
    return nil if user == :false
    
    # Users with consortium access can view/download all result files
    if user.has_consortium_access?
      can [:index, :show_rdef, :show, :fastqc_show, :download], ResultFile
    end

    # Admins have access to all functionality (except edit/delete of other lab's samples)
    if user.has_admin_access?
      can :manage, :all
      cannot [:edit, :update, :delete], Sample do |sample|
        sample.lab_id != user.lab_id
      end
    end
  end
  
end