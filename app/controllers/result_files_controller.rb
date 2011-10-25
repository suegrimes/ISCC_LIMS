class ResultFilesController < ApplicationController
  load_and_authorize_resource
  
  #TODO
  # rm images/fastqcdir after session
  # use session timeout?

  def index
    lab_dir_name = Lab.find(current_user.lab.id).lab_dirname
    @result_files = ResultFile.find(:all, :include => {:seq_lanes => :sample}, :conditions => {:lab_id => current_user.lab.id})
    fastqc_dirs = get_fastqc_dirs(Lab.find(current_user.lab.id).lab_dirname) #gets list of fastqc dirnames
    @fastqc_access = Hash[ *fastqc_dirs.collect { |v| [ rand(36**8).to_s(36), v ] }.flatten ]
    #@fastqc_access[:session_id] = request.session_options[:id]
    # store hash in file as object
    fastqcdir_info_file = File.join(ResultFile::BASE_PATH, lab_dir_name, 'fastqcdir_info.ml') 
    File.open(fastqcdir_info_file,'w') do |file|
      Marshal.dump(@fastqc_access, file)
    end
  end
  
  def fastqc_show 
    
    lab_dir_name = Lab.find(current_user.lab.id).lab_dirname
    key = params[:dir_id]
    
    # get hash of dirnames from file
    fastqcdir_info_hash = Hash.new
    fastqcdir_info_file = File.join(ResultFile::BASE_PATH, lab_dir_name, 'fastqcdir_info.ml')
    File.open(fastqcdir_info_file,'r') do |file|
      fastqcdir_info_hash = Marshal.load(file)
    end   

    fastqc_dir = fastqcdir_info_hash[key]
    fastqc_file = File.join(ResultFile::BASE_PATH, lab_dir_name, fastqc_dir, 'fastqc_report.html')
    fastqc_file_images = File.join(RAILS_ROOT, ResultFile::BASE_PATH, lab_dir_name, fastqc_dir, 'Images/')
    fastqc_file_icons = File.join(RAILS_ROOT, ResultFile::BASE_PATH, lab_dir_name, fastqc_dir, 'Icons/')
    public_images_fastqc_dir = File.join(RAILS_ROOT, '/public/images/', fastqc_dir)

    # check if image subdir for lab exists, then create if not
    unless (File.directory?(public_images_fastqc_dir))
      FileUtils.mkdir(public_images_fastqc_dir) 
    end

    # make symlinks of image folders in images fastqc dir
    FileUtils.ln_s(fastqc_file_icons, public_images_fastqc_dir, :force => true)
    FileUtils.ln_s(fastqc_file_images, public_images_fastqc_dir, :force => true)

    # create report file copy and modify image path
    fastqc_file_cc = File.join(ResultFile::BASE_PATH, lab_dir_name, fastqc_dir, 'fastqc_report_copy.html')
    FileUtils.copy(fastqc_file, fastqc_file_cc) 
    html_imgs_change_path(fastqc_file_cc, lab_dir_name, fastqc_dir)

    send_file(fastqc_file_cc, :type => 'html', :disposition => 'inline')
    
  end
    
  def show
    rfile = ResultFile.find(params[:id]) 
    labname_dir = Lab.find(current_user.lab.id).lab_dirname   
    send_file(File.join(ResultFile::BASE_PATH, labname_dir, rfile[:document]), 
                        :type => rfile[:document_content_type], :disposition => 'inline')
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
    @datafile_path = File.join(ResultFile::BASE_PATH, @chosen_lab.lab_dirname)
       
    @results_on_filesystem = get_files_from_filesystem(@chosen_lab.lab_dirname, @chosen_lab.id)
    if (@results_on_filesystem.blank?) #directory does not exist or is empty
      flash.now[:error] = "Sorry, no result files available for #{@chosen_lab.lab_name}"
      #flash.now[:error] = "Sorry, no result files found for #{@chosen_lab.lab_name} in directory: #{@datafile_path}"
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
    @result_files = ResultFile.find(:all, :include => {:seq_lanes => :sample}, :conditions => {:lab_id => @chosen_lab.id})
    @seq_lanes = SeqLane.find(:all, :conditions => {:lab_id => @chosen_lab.id}, :order => "seq_run_nr, lane_nr")
 
    if (@seq_lanes.blank?)
      flash.now[:error] = "Sorry, no samples matched to sequence runs yet for #{@chosen_lab.lab_name}"
      render :action => 'choose_lab', :locals => {:lab_list => @labs}
      return
    end
   
  end
  
  def update_multi
      
    #@debug_list = []
    @files_updated = 0 # for debug
    params[:result_files].each do |id, rfile| # id is key, rfile is hash of file attributes from the form
      rfile[:seq_lane_ids] ||= []
      #@debug_list.push(rfile)
      result_file = ResultFile.find(id)
      #associating result file with list of lanes            
      result_file.seq_lanes = SeqLane.find(rfile[:seq_lane_ids]) if (!rfile[:seq_lane_ids].empty?)
      if (result_file.update_attributes(rfile))
        @files_updated += 1              
      end
    end
    
    if (@files_updated != 0)
      flash.now[:notice] = @files_updated.to_s + " updates were made to Result Files table"
    end
    
    @chosen_lab = Lab.find(params[:chosen_lab][:id])
    #get result files with associated lanes and samples per lab chosen by admin
    @result_files = ResultFile.find(:all, :include => {:seq_lanes => :sample}, :conditions => {:lab_id => params[:chosen_lab][:id]})
    render :action => 'update_multi_show'    
  end
  
  def destroy     
    result_file = ResultFile.find(params[:id])
    authorize! :delete, ResultFile
    
    result_file.destroy
    lab_dir_name = Lab.find(params[:lab_id]).lab_dirname  
    File.delete(File.join(ResultFile::BASE_PATH, lab_dir_name, result_file.document))     
    
    redirect_to :action => 'edit_multi', :lab_id => params[:lab_id]   
  end
  
  def debug
    render :action => :debug  
  end
  
protected
  
  def get_files_from_filesystem(lab_dir_name, lab_id)
    datafile_path = File.join(ResultFile::BASE_PATH, lab_dir_name) 
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

  def get_fastqc_dirs(lab_dir_name)
    datafile_path = File.join(ResultFile::BASE_PATH, lab_dir_name) # relative path -> university dirname
    dirs_list = get_dir_list(datafile_path, '_fastqc')
    return dirs_list
  end

=begin
  def get_fastqc_html(lab_dir_name)
    datafile_path = File.join(RAILS_ROOT, ResultFile::BASE_PATH, lab_dir_name)
    dirs_list = get_dir_list(datafile_path, '_fastqc')
    
    files_list = []
    dirs_list.each do |fdir|
      next if (fdir[0].chr == '.')
      qcdir_path = File.join(datafile_path, fdir)
      files_list.push(File.join(qcdir_path, get_file_list(qcdir_path, 'html')))
    end

    return files_list.flatten 
  end
=end

=begin
  # get fastqc folder in a zipped format
  def get_fastqc_files(lab_dir_name)
    
    datafile_path = File.join(ResultFile::BASE_PATH, lab_dir_name) 
    
    if (File.directory?(datafile_path))
           
      Dir.chdir(datafile_path)
    
      files_list = []
      Dir.foreach('.') do |fdir| # go through dir looking for fastqc zip files       
        next if ((File.directory?(fn)) || (fn[0].chr == '.'))
        fastqc_dir = fn
        files_list.push(lab_dir_name + '/' + fastqc_dir) if fn.match('fastqc.zip')
      end
         
      Dir.chdir(RAILS_ROOT) 
      
      return files_list
    else    
      return nil    
    end # if datafile path  
  end
=end
  
  # debug for development only
  def trunc_tables
    ResultFile.connection.execute("TRUNCATE TABLE seq_runs")
    ResultFile.connection.execute("TRUNCATE TABLE seq_lanes")
    ResultFile.connection.execute("TRUNCATE TABLE result_files")
    ResultFile.connection.execute("TRUNCATE TABLE result_files_seq_lanes")
  end
  
end