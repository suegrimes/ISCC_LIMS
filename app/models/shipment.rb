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
  
  validates_presence_of :date_shipped, :fedex_tracking_nr
  
  SHIPMENT_DEFAULT = {:date_shipped => Date.today}

  def ship_day(int_or_string='string')
    if int_or_string == 'int'
      return (date_shipped.nil? ? -1 : date_shipped.strftime("%w"))
    else
      return (date_shipped.nil? ? '' : date_shipped.strftime("%A"))
    end
  end
  
  def date_received_or_na
    (date_received.nil? ? 'N/A' : date_received)
  end
end
