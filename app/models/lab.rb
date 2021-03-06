# == Schema Information
#
# Table name: labs
#
#  id         :integer(4)      not null, primary key
#  lab_name   :string(50)      default(""), not null
#  lab_dir    :string(50)
#  created_at :datetime
#

class Lab < ActiveRecord::Base

  validates_presence_of     :lab_name
  validates_uniqueness_of   :lab_name
  
  #scope :user_lab, {:conditions => ["id = ?", User.current_user.lab_id]}
  STANFORD_LAB_ID = 7
  PRINCETON_LAB_ID = 11
  
  def lab_calcdir
    lab_downcase = lab_name.downcase
    return (lab_downcase.match(/\s/) ? lab_downcase.gsub!(/ /, '_') : lab_downcase)
  end
  
  def self.user_lab_dir
    self.find(User.current_user.lab_id).lab_dir
  end
  
end
