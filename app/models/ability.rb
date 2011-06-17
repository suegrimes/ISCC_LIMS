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
    
    # Everyone can manage samples for their own lab only
    can [:new, :create, :index, :show_sop], Sample
    can [:show, :edit, :update, :delete], Sample do |sample|
      sample.lab_id == user.lab_id
    end
    
    can [:new, :create, :index], Shipment
    can [:show, :edit, :update, :delete], Shipment do |shipment|
      shipment.sample.lab_id == user.lab_id
    end
    
    # Everyone can view Results files pages
    can [:index, :link_multi, :update_multi], ResultFile
    
    return nil if user == :false

    # Admins have access to all functionality (except edit/delete of other lab's samples)
    if user.has_admin_access?
      can :manage, :all
      cannot [:edit, :update, :delete], Sample do |sample|
        sample.lab_id != user.lab_id
      end
    end
  end
  
end