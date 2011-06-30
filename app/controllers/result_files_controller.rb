class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @results = ResultFile.find(:all)           
  end
  
  def read_create_files
    
    #ResultFile.connection.execute("TRUNCATE TABLE result_files")
    
    #TODO
    # get contents of result_files table 
    # before save, check if file is already in table - check_result_file(result_file)
    # if so, add to a debug list for display in view
    # if not, .save
    # add to an "added" list, display in view
    # straighten out the link_files_to_samples_form
    
    # temporary until user edit features are in place
    ResultFile.connection.execute("TRUNCATE TABLE result_files")

    @result_files_list = get_files_from_filesystem
    
    files_saved = 0
    @result_files_list.each do |file_info|
      result_file = ResultFile.new(file_info)
      if result_file.save
        files_saved += 1           
      end
    end
    
    if files_saved != 0 
      flash[:notice] = 'Success! ' + files_saved.to_s + ' new Result files saved'
    else
      flash[:error] = 'ERROR - Unable to save result files'
    end
        
    Dir.chdir(RAILS_ROOT)
    
    render :partial => 'link_files_to_samples_form'
    
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
    
    @files_from_filesystem = get_files_from_filesystem

    @samples = Sample.find(:all) 
    #@sample = Sample.find(params[:id])
    
    # this for researchers and admins, to narrow down which files to get; only look in dir for the chosen lab 
    @user_lab_folder = current_user.lab.lab_name.downcase    
    @user_lab_folder = @user_lab_folder.gsub!(/ /, '_') if @user_lab_folder.match(/\s/)
    
    @results = ResultFile.find(:all) 
  end

  def get_files_from_filesystem
    @user_lab_folder = current_user.lab.lab_name.downcase    
    @user_lab_folder = @user_lab_folder.gsub!(/ /, '_') if @user_lab_folder.match(/\s/)
     
    @datafile_path = RAILS_ROOT + '/public/files/dataDownloads/' + @user_lab_folder + '/'    
    Dir.chdir(@datafile_path)
    
    @files_list = [];
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

        @files_list.push(file_info) if (fn[0].chr != '.')                
    }
    return @files_list
  end
  
     # function to check if the file is in table
    #def check_result_file(result_file)
      # check if file is already in the result_files table
      #if result_file_param[:id].blank?
        #return true
      #else
        #return nil
    #end 
  
  def debug
    render :action => :debug  
  end
  
end