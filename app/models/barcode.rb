# == Schema Information
#
# Table name: barcodes
#
#  id                  :integer(1)      not null, primary key
#  last_barcode_number :integer(2)      not null
#

class Barcode < ActiveRecord::Base
  def self.next_barcode
    barcode = Barcode.find(1)
    barcode.update_attributes(:last_barcode_number => barcode.last_barcode_number + 1)
    return barcode[:last_barcode_number]
  end
end
