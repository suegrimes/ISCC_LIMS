class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @result_files = ResultFile.find_and_group_by_lab(current_user)
  end
  
  def show
    rfile = ResultFile.find(params[:id]) 
    send_file(rfile.doc_path(rfile.lab.lab_dir), :type => rfile[:document_content_type], :disposition => 'inline')
  end
  
  def show_rdef
    headers["Content-Type"] = "application/vnd.ms-excel"
    send_file("#{ResultFile::RFILE_RDEF_PATH}") 
  end
  
  def download
    rfile = ResultFile.find(params[:id])
    send_file(rfile.doc_path(rfile.lab.lab_dir), :type => rfile[:document_content_type], :disposition => 'attachment')
  end
  
  def choose_lab
    @labs = Lab.find(:all, :order => :lab_name)    
  end
  
  def check_chosen_lab       
    if (params[:lab] && !params[:lab][:id].blank?)
      redirect_to :action => 'edit_multi', :lab_id => params[:lab][:id]
    else
      flash.now[:error] = 'Choose Lab with Result Files'
      @labs = Lab.find(:all, :order => :lab_name)
      render :action => 'choose_lab'
    end
  end
  
  def edit_multi 
    @labs = Lab.find(:all, :order => :lab_name) 
    @chosen_lab  = Lab.find(params[:lab_id])
    @datafile_path = File.join(ResultFile::ABS_PATH, @chosen_lab.lab_dir)
       
    @results_on_filesystem = get_files_from_filesystem(@chosen_lab.lab_dir, @chosen_lab.id)
    if (@results_on_filesystem.blank?) #directory does not exist or is empty
      #flash.now[:error] = "Sorry, no result files available for #{@chosen_lab.lab_name}"
      flash.now[:error] = "Sorry, no result files found for #{@chosen_lab.lab_name} in directory: #{@datafile_path}"
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
 
    if (@samples.blank?)
      flash.now[:error] = "Sorry, no samples found for #{@chosen_lab.lab_name}"
      render :action => 'choose_lab', :locals => {:lab_list => @labs}
      return
    end
   
  end
  
  def update_multi
      
    #@debug_list = []
    @files_updated = 0 # for debug
    params[:result_files].each do |id, rfile| # id is key, rfile is hash of file attributes from the form
      rfile[:sample_ids] ||= []
      #@debug_list.push(rfile)
      result_file = ResultFile.find(id)
      #associating result file with list of lanes            
      result_file.samples = Sample.find(rfile[:sample_ids]) if (!rfile[:sample_ids].empty?)
      if (result_file.update_attributes(rfile))
        @files_updated += 1              
      end
    end
    
    if (@files_updated != 0)
      flash.now[:notice] = @files_updated.to_s + " updates were made to Result Files table"
    end
    
    @chosen_lab = Lab.find(params[:chosen_lab][:id])
    #get result files with associated lanes and samples per lab chosen by admin
    @result_files = ResultFile.find(:all, :include => :samples, :conditions => {:lab_id => params[:chosen_lab][:id]})
    render :action => 'update_multi_show'    
  end
  
  def destroy     
    result_file = ResultFile.find(params[:id])
    authorize! :delete, ResultFile  
    result_file.destroy
    
    result_lab = Lab.find(params[:lab_id])
    File.delete(result_file.doc_path(result_lab.lab_dir))
    
    redirect_to :action => 'edit_multi', :lab_id => params[:lab_id]   
  end
  
  def debug
    render :action => :debug  
  end
  
protected
  
  def get_files_from_filesystem(lab_dir_name, lab_id)
    datafile_path = File.join(ResultFile::REL_PATH, lab_dir_name) 
    files_list = []
    
    if (File.directory?(datafile_path))
      fn_list = get_file_list(datafile_path)
      fn_list.each do |fn|
        files_list.push({:lab_id => lab_id,
                         :document => fn,
                         :document_content_type => file_content_type(fn),
                         :document_file_size => File.size(File.join(datafile_path,fn)),
                         :updated_by => current_user.id})
      end
    end  
    return files_list
  end

  def public_image_dir(lab_dir=nil)
    if lab_dir.nil? 
      return File.join(RAILS_ROOT, 'public', 'images')
    else
      return File.join(RAILS_ROOT, 'public', 'images', lab_dir)
    end
  end
  
end