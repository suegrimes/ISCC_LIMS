# == Schema Information
#
# Table name: labs
#
#  id         :integer(4)      not null, primary key
#  lab_name   :string(50)      default(""), not null
#  created_at :datetime
#

class Lab < ActiveRecord::Base

  validates_presence_of     :lab_name
  validates_uniqueness_of   :lab_name
  
  STANFORD_LAB_ID = 7
  
  def lab_dirname
    lab_downcase = lab_name.downcase
    return (lab_downcase.match(/\s/) ? lab_downcase.gsub!(/ /, '_') : lab_downcase)
  end
  
end
