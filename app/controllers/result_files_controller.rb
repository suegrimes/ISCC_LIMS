class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @results = ResultFile.find(:all)           
  end
  
  def read_create_files

    @user_lab_folder = current_user.lab.lab_name.downcase    
    @user_lab_folder = @user_lab_folder.gsub!(/ /, '_') if @user_lab_folder.match(/\s/)
     
    @datafile_path = RAILS_ROOT + '/public/files/dataDownloads/' + @user_lab_folder + '/'    
    Dir.chdir(@datafile_path)
    
    @file_system_list = [];
    @result_files_list = [];
    file_info = {};
    Dir.foreach('.') {
        |fn|
        extname = File.extname(fn)[1..-1]
        mime_type = Mime::Type.lookup_by_extension(extname)
        content_type = mime_type.to_s unless mime_type.nil?
         
          file_info = {
            :lab_id => current_user.lab.id,
            :document => fn,
            :document_content_type => content_type,
            :document_file_size => File.size(fn),
            :updated_by => current_user.auth_user.name
          }

        @result_files_list.push(file_info) if (fn[0].chr != '.') 
        @file_system_list.push([fn, File.size(fn), content_type, current_user.lab.id, current_user.auth_user.name]) if (fn[0].chr != '.')   
    }
        
    Dir.chdir(RAILS_ROOT)
    
    #TODO
    # build array of hashes
    #@results_files = []
    # loop through list
    #@results_files.push(
    #  {:document => '', ...}  
    #)
    # save to results_files table
    
    render :partial => 'list_result_files', :locals => { :file_list => @file_system_list, :file_hash_list => @result_files_list }
    
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
        @file_system_list.push([fn, File.size(fn), content_type, current_user.lab.id, current_user.auth_user.name]) if (fn[0].chr != '.')
    }
    
    #@list_files = Dir.glob("*")
    
    Dir.chdir(RAILS_ROOT)
  end
  
  def debug
    render :action => :debug  
  end
  
end