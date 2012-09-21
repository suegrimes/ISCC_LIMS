# == Schema Information
#
# Table name: result_files
#
#  id                    :integer(4)      not null, primary key
#  document              :string(255)
#  document_content_type :string(40)
#  document_file_size    :string(25)
#  notes                 :string(255)
#  lab_id                :integer(4)
#  updated_by            :integer(4)
#  created_at            :datetime
#

class ResultFile < ActiveRecord::Base
  has_and_belongs_to_many :samples
  belongs_to :lab
  belongs_to :user, :foreign_key => :updated_by
    
  REL_PATH = (CAPISTRANO_DEPLOY ? File.join("..", "..", "shared", "data_files") : "data_files")
  ABS_PATH = File.join(RAILS_ROOT, REL_PATH)
  #BASE_PATH = File.join('..','..','ISCC_RNASeq')
  #BASE_PATH = File.join('..','..','test', 'dataDownload')
  
  def doc_path(lab_dir)
    File.join(self.class::ABS_PATH, lab_dir, document)
  end
end
