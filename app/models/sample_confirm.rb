# == Schema Information
#
# Table name: sample_confirm
#

class SampleConfirm < NoTable
  class << self
    def table_name
      self.name.tableize
    end
  end
  
  column :number_of_cells,   :integer
  column :sample_barcode,    :integer
  column :shipment_day,      :integer
  column :dry_ice_75,        :integer
  column :fedex_number,      :integer
  column :ship_notification, :integer

  validates_confirmation_of :number_of_cells, :sample_barcode
end
