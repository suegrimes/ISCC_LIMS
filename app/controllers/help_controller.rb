class HelpController < ApplicationController
  #skip_before_filter :login_required
  FILE_PATH = File.join(RAILS_ROOT, "public/files/result_files")
  #FILE_PATH = File.join(RAILS_ROOT, "../dataDownloads")
  
  def figure_1 
   #file_path = File.join(RAILS_ROOT, "public/images", "")
   send_file(File.join(FILE_PATH, "LgrNucDist.jpg"), :type => 'image/png', :disposition => 'inline')
  end
 
#for testing, hardcoded here, 
#later loop through these, capturing file name, trunc the filetype
  def table_1
    @table1 = read_table(File.join(FILE_PATH, "Lgr_prelim_FPKM.txt"))
    #send_file(File.join(FILE_PATH, "Lgr_prelim_FPKM.txt"), :type => 'text/csv', :disposition => 'inline')
  end
  
  def table_2
    #@table2 = read_table(File.join(FILE_PATH, "Lgr_prelim_FPKM.xls"))
    send_file(File.join(FILE_PATH, "Lgr_prelim_FPKM.xls"), :type => 'xls', :disposition => 'inline')
  end
  
  def annotations 
  end

protected
  def read_table(file_path)
    FasterCSV.read(file_path, {:col_sep => "\t"})
  end
end
