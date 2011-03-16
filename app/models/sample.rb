# == Schema Information
#
# Table name: samples
#
#  id                           :integer(4)      not null, primary key
#  barcode_key                  :string(8)       default(""), not null
#  sample_name                  :string(25)
#  sample_date                  :date
#  organism                     :string(20)
#  strain                       :string(15)
#  sex                          :string(6)
#  age_in_weeks                 :string(2)
#  intestinal_region            :string(50)
#  intestinal_region_definition :string(255)
#  intestinal_sc_marker         :string(50)
#  isolation_protocol_id        :integer(4)
#  facs_protocol_id             :integer(4)
#  sc_marker_validation_method  :string(50)
#  secondary_validation_results :string(255)
#  molecule_type                :string(10)
#  comments                     :string(255)
#  lab_id                       :integer(4)      not null
#  updated_by                   :integer(4)
#  created_at                   :datetime
#  updated_at                   :timestamp       not null
#

class Sample < ActiveRecord::Base
  belongs_to :lab
  has_one :shipment
  
  accepts_nested_attributes_for :shipment, :allow_destroy => true
  
  validates_presence_of :barcode_key, :sample_name, :sample_date, :organism, :strain, :age_in_weeks,
                        :intestinal_region
  
  validates_numericality_of :age_in_weeks, :only_integer => true, :message => "must be an integer"
  #validates_inclusion_of :age_in_weeks, :in => 6..10, :message => "must be between 6 and 10"
  
  named_scope :userlab, lambda{|user| {:conditions => (user.has_admin_access? ? nil : ["samples.lab_id = ?", user.lab_id])}}
  
  STRAINS    = ['C57BI/6J']
  SEX = ['Male', 'Female']
  SC_MARKERS = ['Lgr5 hi', 'Lgr5 lo', 'Bmi1', 'SP hi', 'SP lo', 'label-retaining', 'CD166',
                'CD24', 'p-beta-catS552', 'Mus-1', 'DCAMKL']
  MARKER_VALIDATION = ['none', 'qPCR', 'clonogenic culture', '2nd FACS sort'] 
  
  SAMPLE_DEFAULT = {:sample_date => Date.today,
                    :organism => 'Mus musculus',
                    :strain => STRAINS[0],
                    :sex => 'Male',
                    :age_in_weeks => 6}
                    
  SAMPLE_SOP_PATH = File.join(RAILS_ROOT, 'public', 'files', 'Sample_Shipping_SOP.doc')

end
