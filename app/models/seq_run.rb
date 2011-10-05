# == Schema Information
#
# Table name: seq_runs
#
#  id             :integer(4)      not null, primary key
#  seq_run_nr     :integer(2)      not null
#  seq_run_name   :string(50)
#  date_sequenced :date
#  updated_at     :datetime
#  updated_by     :integer(4)
#

class SeqRun < ActiveRecord::Base
  has_many :seq_lanes
  accepts_nested_attributes_for :seq_lanes
  
  validates_presence_of :seq_run_nr
  
  NR_LANES = 8 
  
  def id_name
    [seq_run_nr, seq_run_name].join('/')
  end
  
  def build_seq_lanes(lanes)
    lanes.reject!{|lane| lane[:lane_nr].blank?}
    
    lanes.each do |lane|
      lane_nrs = lane[:lane_nr].split(',')
      lane_nrs[0..(lane_nrs.size - 1)].each_with_index do |lnr, i|
        lane[:lane_nr] = lnr
        lane.merge!(:seq_run_nr => seq_run_nr, :seq_run_name => seq_run_name)
        seq_lanes.build(lane)
      end  
    end
  end
end
