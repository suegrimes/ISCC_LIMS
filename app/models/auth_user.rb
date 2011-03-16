# == Schema Information
#
# Table name: auth_users
#
#  id         :integer(2)      not null, primary key
#  lab_id     :integer(2)      not null
#  name       :string(50)      default(""), not null
#  email      :string(75)      default(""), not null
#  notes      :string(255)
#  created_at :datetime        not null
#  updated_at :timestamp
#

class AuthUser < ActiveRecord::Base
  include Authentication
  
  belongs_to :lab
  has_one :user
  
  validates_presence_of     :lab_id, :email, :name
  
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

end
