module SamplesHelper
  def ship_weekday(shipment, int_or_string='string')
    if int_or_string == 'int'
      return (shipment.date_shipped.nil? ? -1 : shipment.date_shipped.strftime("%w"))
    else
      return (shipment.date_shipped.nil? ? '' : shipment.date_shipped.strftime("%A"))
    end
  end
end
