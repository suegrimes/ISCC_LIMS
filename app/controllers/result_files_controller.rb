class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @results = ResultFile.find(:all)           
  end
  
  def edit_multi
    # TODO
    # concatate Sample name with Barcode
    # write to sample_results
    # get the list of linked samples from results_files from logged in's lab
    # compare lists from file sys to this list. 
    # Pass Union of lists to file list and Intersection determines already linked status (greyed or whatnot)
    # figure out with Sue what angle to offer admins: link file to samples or link sample to files
        
    @samples = Sample.find(:all) 
    #@sample = Sample.find(params[:id])
    
    # this for researchers and admins, to narrow down which files to get; only look in dir for the chosen lab 
    @user_lab_folder = current_user.lab.lab_name.downcase    
    @user_lab_folder = @user_lab_folder.gsub!(/ /, '_') if @user_lab_folder.match(/\s/)
    
    @results = ResultFile.find(:all)
            
    #@datafile_path = RAILS_ROOT + 'public/files/dataDownloads/' + @user_lab_folder + '/'
    @datafile_path = RAILS_ROOT + '/public/files/dataDownloads/' + @user_lab_folder + '/'    
    Dir.chdir(@datafile_path)
    
    @file_system_list = [];
    Dir.foreach('.') {
        |fn|
        extname = File.extname(fn)[1..-1]
        mime_type = Mime::Type.lookup_by_extension(extname)
        content_type = mime_type.to_s unless mime_type.nil?
        @file_system_list.push([fn, File.size(fn), content_type]) if (fn[0].chr != '.')
    }
    
    # for now until list created after checking both db and filesys
    @file_list = @file_system_list; 
    
    #@list_files = Dir.glob("*")
    
    Dir.chdir(RAILS_ROOT)
  end
  
  def debug
    
  end

end