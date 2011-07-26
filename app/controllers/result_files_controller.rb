class ResultFilesController < ApplicationController
  load_and_authorize_resource
  
  def index
    #TODO: 
    # this doesn't work from the Samples List Results button
    # get ResultFiles object with Sample included    
    @which_view = 'DEBUG: default render of index from Samples List Results button' # for debug
    @samples = Sample.find(:all, :include => :result_files, :conditions => {:id => params[:chosen_sample_id], :lab_id => params[:user_lab_id]})
  end
    
  def show
    # TODO
    # get chosen lab name
    # make condition for if from admin use chosen lab name or
    # from user use user lab name
    labname_dir = current_user.lab.lab_name.downcase
    #labname_dir = 'nih'
    labname_dir = labname_dir.gsub!(/ /, '_') if labname_dir.match(/\s/)
    @datafile_path = RAILS_ROOT + '/public/files/dataDownloads/' + labname_dir + '/' 
    rfile = ResultFile.find(params[:id])
    # TODO: see seqLIMS attached_files_controller show method
    send_file(File.join(@datafile_path, rfile[:document]), :type => rfile[:document_content_type], :disposition => 'inline')
  end
  
  def choose_lab
    @labs = Lab.find(:all, :order => :lab_name)    
  end
  
  def check_chosen_lab
    @labs = Lab.find(:all, :order => :lab_name)
    @chosen_lab_id = params[:lab][:id] if (!params[:lab][:id].blank?) 
    if (params[:lab][:id].blank?)
       flash.now[:error] = 'Choose Lab with Result Files'
       render :action => 'choose_lab'
    else
      redirect_to :action => 'edit_multi', :lab_id => @chosen_lab_id
    end
  end
  
  def edit_multi 
  # clear tables
  #ResultFile.connection.execute("TRUNCATE TABLE result_files")
  #ResultFile.connection.execute("TRUNCATE TABLE result_files_samples")

  # TODO
  # on view, all lab and user id's converted to name
  ## query result_files for updated_by (an id#), then query auth_user table by id# to get list of names
  ## make a hash or ? to connect the file with this name rather than their id# for display in the link form
  # localize variables
  # take out unneeded variables 

  # Admin Auth 

    @labs = Lab.find(:all, :order => :lab_name) 
    @chosen_lab  = Lab.find_by_id(params[:lab_id])
    chosen_lab_dir_name = @chosen_lab.lab_name.downcase
    chosen_lab_dir_name = chosen_lab_dir_name.gsub!(/ /, '_') if chosen_lab_dir_name.match(/\s/)
    chosen_lab_dir_id   = @chosen_lab.id
       
    @results_on_filesystem = get_files_from_filesystem(chosen_lab_dir_name, chosen_lab_dir_id)
    if (@results_on_filesystem.blank?) #directory does not exist or is empty
      flash.now[:error] = "Sorry, no result files available for #{@chosen_lab.lab_name}"
      render :action => 'choose_lab', :locals => {:lab_list => @labs}
      return
    end
    
    @result_files_before_save = ResultFile.find(:all, :conditions => {:lab_id => @chosen_lab.id})
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
    @result_files = ResultFile.find(:all, :include => :samples, :conditions => {:lab_id => @chosen_lab.id})
    @samples = Sample.find(:all, :conditions => {:lab_id => @chosen_lab.id}) 
   
  end
  
  def update_multi
  
  # TODO
  # get ResultFiles object with Sample included
    
    @debug_list = []
    @files_updated = 0 # for debug
    params[:result_files].each do |id, rfile| # id is key, rfile is hash of file attributes from the form
      @debug_list.push(rfile)
      result_file = ResultFile.find(id)
      #associating result file with list of samples based on sample id(s) from form
      result_file.samples = Sample.find(rfile[:sample_ids]) if (rfile[:sample_ids]) 
      if (result_file.update_attributes(:notes => rfile[:notes]))
        @files_updated += 1              
      end
    end
    
    if (@files_updated != 0)
      flash.now[:notice] = @files_updated.to_s + " updates were made to Result Files table"
    end
    
    #get samples with associated result files per lab chosen by admin
    @samples = Sample.find(:all, :include => :result_files, :conditions => {:lab_id => params[:chosen_lab][:id]})
    @which_view = 'DEBUG: render from update_multi' # for debug
    render :action => 'index'    
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