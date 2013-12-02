class ShipmentObserver < ActiveRecord::Observer
  #def after_create(shipment)
  #  ShipmentMailer.deliver_shipment_notification(shipment, 'new')
  #end
  
  def after_save(shipment)
    if shipment.new_record?
      ShipmentMailer.shipment_notification(shipment, 'new').deliver
    elsif shipment.fedex_tracking_nr_changed?
      ShipmentMailer.shipment_notification(shipment, 'upd').deliver
    end
  end
end
