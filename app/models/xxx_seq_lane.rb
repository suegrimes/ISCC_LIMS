# == Schema Information
#
# Table name: seq_lanes
#
#  id           :integer(4)      not null, primary key
#  lane_nr      :integer(1)      not null
#  seq_run_id   :integer(2)
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
  has_one :seq_qc
  belongs_to :sample
  
  has_and_belongs_to_many :result_files 
  
  scope :userlab, lambda{|user| {:conditions => (user.has_admin_access? ? nil : ["seq_lanes.lab_id = ?", user.lab_id])}}
 
  def run_lane_sample
    seqrun_num = 'Run #' + seq_run_nr.to_s
    lane = 'Lane ' + lane_nr.to_s
    sample = 'Sample ' + self.sample.barcode_key
    [seqrun_num, lane, sample].join('/')
  end
  
end
