class ShipmentMailer < ActionMailer::Base  
  TO_EMAIL_LIST   = (RAILS_ENV == 'production' ? ['wilhelmy@stanford.edu', 'genomics_ji@stanford.edu'] : ['sgrimes@stanford.edu'])
  FROM_EMAIL      = 'iscc_noreply@stanford.edu'
  
  def shipment_notification(shipment, new_or_upd)
    setup_email(shipment, User.find_by_id(shipment.sample.updated_by), new_or_upd)
    @subject    += 'Sample shipment notification'
  end
  
  protected
    def setup_email(shipment, user, new_or_upd)
      @recipients  = TO_EMAIL_LIST
      @from        = FROM_EMAIL
      @subject     = "ISCC RNASeq: "
      @sent_on     = Time.now
      @body        = {:new_or_upd => new_or_upd,
                      :shipment   => shipment,
                      :sample     => shipment.sample,
                      :user_login => (user.nil? ? 'N/A' : user.login)}
    end
end
