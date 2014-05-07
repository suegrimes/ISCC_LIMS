class ShipmentMailer < ActionMailer::Base

  default content_type: 'text/html', from: 'iscc_noreply@stanford.edu'

  def shipment_notification(shipment, new_or_upd)
    @shipment = shipment
    @sample = shipment.sample
    @user = User.find_by_id(@sample.updated_by)
    @new_or_upd = new_or_upd
    mail(:subject => 'ISCC RNASeq: Sample shipment notification',
         :to => (Rails.env == 'production' ? ['julie.wilhelmy@gmail.com', 'ksyan@stanford.edu'] : ['sgrimes@stanford.edu']))
  end
end
