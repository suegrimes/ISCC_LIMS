class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @results = ResultFile.find(:all)           
  end
  
  def read_create_files
    # TODO
    # get this to control the partial, _list_result_files for debugging
    # show files from system at top of page after clicking button (get new files)
    # for debug, show the files
    # create data structure for writing to results_files table
    # save to table     
    
  end
  
  def link_multi
    #authorize! :create, ResultFile

    # TODO
    # display all files with the lab.id in form
    # checked or not depending on if already linked
    # user can: link samples, update, delete(?)
    # some handy code examples from Sue:
      # result_file = ResultFile.find(params[:result_file][:id])
      # result_file.update_attributes(params[:result_file])
      # result_file.samples = Sample.find(params[:result_file][:sample_ids])
      # result_file.save      
    # also see her mail of 6/22
    # !!! Ask Sue how to get a partial to show up and get it to use a function in the controller other than this one!!!

    # function to check if the file is in table
    #def check_result_file(result_file_param)
      # check if file is already in the result_files table
      #if result_file_param[:id].blank?
        #return true
      #else
        #return nil
    #end 
    
    # the following code is temporary 

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
  
  def debug
    render :action => :debug  
  end
  
end