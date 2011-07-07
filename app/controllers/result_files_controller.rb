class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @results = ResultFile.find(:all)           
  end
  
  def read_files_create
    
    #ResultFile.connection.execute("TRUNCATE TABLE result_files")
    
  # TODO
  # query result_files table
  # check if file is already in result_files table
  ## if not in results_files table, make list and display as recent files added
  ## .save
 
  # query linked table
  # query results_files and if file is in linked table
  ## make list to pass to the form for checked status
  ## check if file is in the linked list
  ## if not display as unchecked
  ## else display as checked 
  
  ## validation for No Lab Selected
    
    # temporary until user edit features are in place
    ResultFile.connection.execute("TRUNCATE TABLE result_files")

    @lab = Lab.find(params[:lab][:id])    
    lab_dir_name = @lab.lab_name.downcase
    lab_dir_name = lab_dir_name.gsub!(/ /, '_') if lab_dir_name.match(/\s/) 
       
    @result_files_list = get_files_from_filesystem(lab_dir_name)
    
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
    
    @labs = Lab.find(:all, :order => :lab_name)
    @result_files = ResultFile.find(:all)
    @samples = Sample.find(:all)     
    
    render :action => 'link_multi'
    
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
 
    @labs = Lab.find(:all, :order => :lab_name)
    @result_files = ResultFile.find(:all)
    @samples = Sample.find(:all)     
       
  end

  def get_files_from_filesystem(dir_name)
    
    # TODO - change current user lab to chosen lab
     
    @datafile_path = RAILS_ROOT + '/public/files/dataDownloads/' + dir_name + '/'    
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