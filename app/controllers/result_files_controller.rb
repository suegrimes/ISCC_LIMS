class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @labs = Lab.find(:all, :order => :lab_name)    
  end
  
  def check_chosen_lab
    @labs = Lab.find(:all, :order => :lab_name)
    @chosen_lab_id = params[:lab][:id] if (!params[:lab][:id].blank?) 
    if (params[:lab][:id].blank?)
       flash.now[:error] = 'Choose Lab with Result Files'
       render :action => 'index'
    else
      redirect_to :action => 'link_multi', :lab_id => @chosen_lab_id
    end
  end
  
  def link_multi
  
  # clear db
  #ResultFile.connection.execute("TRUNCATE TABLE result_files")
    
  # TODO
  # make flash message disappear from subsequent pages

  # SAVE TO LINKED TABLE
  # query linked table
  # query results_files
  # if result_file already in linked table:
  ## display as checked 
  ## else display as unchecked

  # query result_files for updated_by (an id#), then query auth_user table by id# to get list of names
  # make a hash or ? to connect the file with this name rather than their id# for display in the link form

  # localize variables
  # take out unneeded variables

  # some handy code examples from Sue:
      # result_file = ResultFile.find(params[:result_file][:id])
      # result_file.update_attributes(params[:result_file])
      # result_file.samples = Sample.find(params[:result_file][:sample_ids])
      # result_file.save      
  # also see her mail of 6/22
 
  # add update, edit 

    @labs = Lab.find(:all, :order => :lab_name) 
    @lab = Lab.find_by_id(params[:lab_id])
    lab_dir_name = @lab.lab_name.downcase
    lab_dir_name = lab_dir_name.gsub!(/ /, '_') if lab_dir_name.match(/\s/) 
       
    @results_on_filesystem = get_files_from_filesystem(lab_dir_name, @lab.id)
    if (@results_on_filesystem.blank?) #directory does not exist or is empty
      flash[:error] = "Sorry, no result files available for #{@lab.lab_name}"
      render :action => 'index', :locals => {:lab_list => @labs}
      return
    end
    
    @result_files_before_save = ResultFile.find(:all, :conditions => {:lab_id => @lab.id})
    documents_in_db = @result_files_before_save.collect(&:document) if (!@result_files_before_save.blank?)

    @exist_in_db = []; @new_files = [];
    @files_saved = 0 # for debug
    @results_on_filesystem.each do |file_on_system_info|   
      # check if file is already in the table
      if (documents_in_db.blank?) || (!documents_in_db.include?(file_on_system_info[:document]))
        @new_files.push(file_on_system_info[:document])
        result_file = ResultFile.new(file_on_system_info)
        if result_file.save
          @files_saved += 1           
        end # if
      else
        @exist_in_db.push(file_on_system_info[:document])
      end # if
    end # each
            
    # get data for link form        
    @result_files = ResultFile.find(:all, :conditions => {:lab_id => @lab.id})
    @samples = Sample.find(:all)   
   
  end
  
  def link_files_to_samples    
    
    @debug_list = []
    @files_updated = 0 # for debug
    params[:result_files].each do |rfile|
      @debug_list.push(rfile)
      result_file = ResultFile.find(rfile[:id])
      result_file.samples = Sample.find(rfile[:sample_id]) #associating result file with list of samples based on id
      if (result_file.update_attributes(:notes => rfile[:notes]))
        @files_updated += 1              
      end
    end
    
    if (@files_updated != 0)
      flash.now[:notice] = @files_updated.to_s + " updates were made to Result Files table"
    end
    
    #@results_updated = ResultFile.find(:all, :conditions => {:lab_id => params[:temp][:user_lab_id]})
    #@samples = Sample.find(:all, :include => :result_files, :conditions => {:id => [1,18,39]})
    @samples = Sample.find(:all, :include => :result_files) #get samples with associated result files
    
  end
  
  def debug
    render :action => :debug  
  end
  
protected
  
  def get_files_from_filesystem(dir_name, lab_id)
    # TODO
    # localize variables
    
    # check if directory exists
    datafile_path = RAILS_ROOT + '/public/files/dataDownloads/' + dir_name + '/' 
    if (File.directory?(datafile_path))
           
      Dir.chdir(datafile_path)
    
      files_list = [];
      file_info = {};
      Dir.foreach('.') {
        |fn|
        extname = File.extname(fn)[1..-1]
        mime_type = Mime::Type.lookup_by_extension(extname)
        content_type = mime_type.to_s unless mime_type.nil?
         
        file_info = {
          :lab_id => lab_id,
          :document => fn,
          :document_content_type => content_type,
          :document_file_size => File.size(fn),
          :updated_by => current_user.auth_user.id
        }
        files_list.push(file_info) if (fn[0].chr != '.')                
      }
      
      Dir.chdir(RAILS_ROOT)    
      return files_list   
    else    
      return nil    
    end
  end
  
end