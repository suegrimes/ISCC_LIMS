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
  
  named_scope :userlab, lambda{|user| {:conditions => (user.has_consortium_access? ? nil : ["result_files.lab_id = ?", user.lab_id])}}
    
  REL_PATH = (CAPISTRANO_DEPLOY ? File.join("..", "..", "shared", "data_files") : File.join("..", "..", "ISCC_RNASeq"))
  ABS_PATH = File.join(RAILS_ROOT, REL_PATH)
  RFILE_RDEF_PATH = File.join(RAILS_ROOT, 'public', 'files', 'Result_ColumnDefs.xls')
  #BASE_PATH = File.join('..','..','ISCC_RNASeq')
  #BASE_PATH = File.join('..','..','test', 'dataDownload')
  
  def fileMB
    mb_size = document_file_size.to_f / 1024 / 1024
    return sprintf("%.2f", mb_size)
  end
  
  def doc_path(lab_dir)
    File.join(self.class::ABS_PATH, lab_dir, document)
  end
  
  def self.find_and_group_by_lab(user, condition_array=nil)
    rfiles = self.userlab(user).find(:all, :include => :samples, :order => 'result_files.lab_id',
                                      :conditions => condition_array)
    return rfiles.group_by {|rfile| rfile.lab.lab_name}
  end
end
