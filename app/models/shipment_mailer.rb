class ShipmentMailer < ActionMailer::Base
  TO_EMAIL_LIST   = (RAILS_ENV == 'production' ? ['wilhelmy@stanford.edu', 'genomics_ji@stanford.edu'] : ['sgrimes@stanford.edu'])
  FROM_EMAIL      = 'iscc_admin@stanford.edu'
  
  def shipment_notification(shipment)
    setup_email(shipment)
    @subject    += 'Please activate your new account'
    @body[:url]  = "http://#{SITE_URL}/activate/#{user.activation_code}"
  end
  
  protected
    def setup_email(shipment)
      @recipients  = TO_EMAIL_LIST
      @from        = FROM_EMAIL
      @subject     = "ISCC RNASeq: "
      @sent_on     = Time.now
      @body[:shipment] = shipment
    end
end
