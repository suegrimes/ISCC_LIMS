class Condition < ActiveRecord::Base
  belongs_to :lab
  has_many :samples
  has_many :result_files
  
  accepts_nested_attributes_for :result_files, :allow_destroy => true
  
  named_scope :userlab, lambda{|user| {:conditions => ["conditions.lab_id = ?", user.lab_id]}}
  
end
