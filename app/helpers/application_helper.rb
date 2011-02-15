# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def toggle_div(div, div1=nil)
    update_page do |page|
      page[div].toggle
      page[div1].toggle if div1
    end
  end
end
