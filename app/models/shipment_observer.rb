class ShipmentObserver < ActiveRecord::Observer
  def after_create(shipment)
    ShipmentMailer.deliver_shipment_notification(shipment)
  end
end
