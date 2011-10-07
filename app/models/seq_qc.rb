# == Schema Information
#
# Table name: seq_qc
#
#  id                       :integer(4)      not null, primary key
#  seq_lane_id              :integer(4)      not null
#  seq_run_nr               :integer(2)
#  seq_run_name             :string(50)
#  lane_nr                  :integer(1)
#  lane_yield               :integer(4)
#  clusters_raw             :integer(4)
#  clusters_pf              :integer(4)
#  cycle1_intensity_pf      :integer(4)
#  cycle20_intensity_pct_pf :integer(4)
#  pct_pf_clusters          :decimal(6, 2)
#  pct_align_pf             :decimal(6, 2)
#  align_score_pf           :decimal(8, 2)
#  pct_error_rate_pf        :decimal(6, 2)
#  nr_NM                    :integer(4)
#  nr_QC                    :integer(4)
#  nr_RX                    :integer(4)
#  nr_U0                    :integer(4)
#  nr_U1                    :integer(4)
#  nr_U2                    :integer(4)
#  nr_UM                    :integer(4)
#  nr_nonuniques            :integer(4)
#  nr_uniques               :integer(4)
#  min_insert               :integer(2)
#  max_insert               :integer(2)
#  median_insert            :integer(2)
#  total_reads              :integer(4)
#  pf_reads                 :integer(4)
#  failed_reads             :integer(4)
#  notes                    :string(255)
#  created_at               :datetime
#  updated_at               :timestamp
#

class SeqQc < ActiveRecord::Base
  set_table_name 'seq_qc'
  
  belongs_to :seq_lane
end
