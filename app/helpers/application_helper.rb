module ApplicationHelper
    
  def user_has_access?(user_roles, valid_roles)
    # if user has admin role, or intersection of user_roles and valid_roles is not empty, user has access
    (user_roles.include?("admin") || (user_roles & valid_roles).size > 0 ? true : false)
  end
  
  def div_toggle(div, div1=nil)
    update_page do |page|
      page[div].toggle
      page[div1].toggle if div1
    end
  end
  
  def show_attribute(obj, attribute_name)
    if current_user.has_admin_access?
      return obj.send(attribute_name)
    else
      return "hidden"
    end
  end
  
  def format_date(datetime)
    (datetime.nil? ? '' : datetime.strftime("%Y-%m-%d"))
  end
  
  def format_datetime(datetime)
    (datetime.nil? ? '' : datetime.strftime("%Y-%m-%d %I:%M%p"))
  end
  
  def day_of_week(datetime)
    (datetime.nil? ? '' : datetime.strftime("%A"))
  end
  
  def break_clear(content=nil)
    out = '<br />'
    out << '<table class="break_clear" width="100%"><tr><td>'
    out << content if !content.nil?
    out << '</td></tr></table>'
    out
  end
  
end
