# == Schema Information
#
# Table name: shipments
#
#  id                :integer(4)      not null, primary key
#  sample_id         :integer(4)      not null
#  date_shipped      :date
#  fedex_tracking_nr :string(50)
#  date_received     :date
#  comments          :string(255)
#  updated_by        :integer(4)
#  updated_at        :timestamp
#

class Shipment < ActiveRecord::Base

  belongs_to :sample
  
  validates_presence_of :sample_id, :date_shipped, :fedex_tracking_nr

end
