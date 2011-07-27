# == Schema Information
#
# Table name: seq_lanes
#
#  id           :integer(4)      not null, primary key
#  lane_nr      :integer(1)      not null
#  seq_run_nr   :integer(2)      not null
#  seq_run_name :string(25)
#  sample_id    :integer(4)      not null
#  lab_id       :integer(4)      not null
#  updated_at   :datetime
#  updated_by   :integer(4)
#

class SeqLane < ActiveRecord::Base
  belongs_to :lab
  belongs_to :seq_run
  belongs_to :sample
  has_one :seq_qc
  
  named_scope :userlab, lambda{|user| {:conditions => (user.has_admin_access? ? nil : ["seq_lanes.lab_id = ?", user.lab_id])}}
  
end
