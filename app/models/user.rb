# == Schema Information
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(25)      default(""), not null
#  lab_id                    :integer(4)      not null
#  email                     :string(255)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  activation_code           :string(50)
#  activated_at              :datetime
#  reset_code                :string(50)
#  updated_at                :datetime
#  remember_token            :string(255)
#  remember_token_expires_at :datetime
#

require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  
  validates_presence_of     :lab_id

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  #validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  #validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  before_create :make_activation_code 
  
  # Class virtual attribute for current_user (set in application controller)
  cattr_accessor :current_user
  
  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :lab_id, :login, :email, :password, :password_confirmation


  # Activates the user in the database.
  def activate!
    @activated = true
    self.activated_at = Time.now.utc
    self.activation_code = nil
    save(false)
  end

  # Returns true if the user has just been activated.
  def recently_activated?
    @activated
  end

  def active?
    # the existence of an activation code means they have not activated yet
    activation_code.nil?
  end
  
  def recently_activated?
    @activated
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(lab_id, login, password)
    return nil if login.blank? || password.blank?
    u = find :first, :conditions => ['login = ? AND lab_id = ? AND activated_at IS NOT NULL', login, lab_id] # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

protected
  def make_activation_code
    self.activation_code = self.class.make_token
  end
  
  def create_reset_code
    @reset = true
    self.attributes = {:reset_code => Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by {rand}.join)}
    save(false)
  end
  
  def recently_reset?
    @reset
  end
  
  def delete_reset_code
    self.attributes = {:reset_code => nil}
    save(false)
  end
end