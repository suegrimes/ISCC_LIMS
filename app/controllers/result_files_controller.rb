class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @results = ResultFile.find(:all)           
  end
  
  def link_multi
    # TODO
       
    # get the list of linked samples from results_files - where logged in's lab
    # compare list from file sys from logged in's lab to this list. 
    # If result file is in the db, add the id (for checked status) and updated_by name
    # write submit to sample_results and linked file
        
    @samples = Sample.find(:all) 
    #@sample = Sample.find(params[:id])
    
    # this for researchers and admins, to narrow down which files to get; only look in dir for the chosen lab 
    @user_lab_folder = current_user.lab.lab_name.downcase    
    @user_lab_folder = @user_lab_folder.gsub!(/ /, '_') if @user_lab_folder.match(/\s/)
    
    @results = ResultFile.find(:all)
 
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
  
  def update_multi
    render :action => :debug
    
    #@result_files = ResultFile.find(params[:id])
    
    #if @result_files.update_attributes(params[:result_files])
    #  flash[:notice] = 'Result Files were successfully linked to Samples'
    #  redirect_to(@result_files)
    #else
    #  flash[:error] = 'Error linking Files to Samples'
    #  dropdowns
    #  render :action => 'edit'
    #end
  end

end