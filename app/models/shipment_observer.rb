class ShipmentObserver < ActiveRecord::Observer
  def after_create(shipment)
    ShipmentMailer.deliver_shipment_notification(shipment)
  end
  
  def after_save(shipment)
    ShipmentMailer.deliver_shipment_notification(shipment) if shipment.fedex_tracking_nr_changed?
  end
end
