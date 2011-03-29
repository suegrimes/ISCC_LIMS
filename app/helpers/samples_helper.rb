module SamplesHelper
  def ship_weekday(date_shipped, int_or_string='string')
    if int_or_string == 'int'
      return (date_shipped.nil? ? -1 : date_shipped.strftime("%w"))
    else
      return (date_shipped.nil? ? '' : date_shipped.strftime("%A"))
    end
  end
end
