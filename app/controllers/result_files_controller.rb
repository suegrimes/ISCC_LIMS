class ResultFilesController < ApplicationController
  load_and_authorize_resource
  
  #DATAFILES = RAILS_ROOT + '/public/files/dataDownloads/'
  DATAFILES = '/Users/jennifer/dev/test/dataDownloads/'

  
  def index
    @result_files = ResultFile.find(:all, :include => {:seq_lanes => :sample}, :conditions => {:lab_id => current_user.lab.id})
    labname_dir = current_user.lab.lab_name.downcase       
    labname_dir = labname_dir.gsub!(/ /, '_') if labname_dir.match(/\s/) 
    @fastqc_files = get_fastqc_files(labname_dir)
  end
  
  def fastqc_show    
    @fastqc_file = params[:file_path]
    headers["Content-Type"] = "zip"
    send_file(DATAFILES + @fastqc_file)
  end
    
  def show
    # TODO
    #see seqLIMS attached_files_controller show method
 
    rfile = ResultFile.find(params[:id]) 
    labname_dir = current_user.lab.lab_name.downcase       
    labname_dir = labname_dir.gsub!(/ /, '_') if labname_dir.match(/\s/)        
    @datafile_path = DATAFILES + labname_dir + '/'
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

  # TODO

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
    @result_files = ResultFile.find(:all, :include => {:seq_lanes => :sample}, :conditions => {:lab_id => @chosen_lab.id})
    #@samples = Sample.find(:all, :conditions => {:lab_id => @chosen_lab.id}) 
    @seq_lanes = SeqLane.find(:all, :conditions => {:lab_id => @chosen_lab.id}, :order => "seq_run_nr, lane_nr")
 
    if (@seq_lanes.blank?)
      flash.now[:error] = "Sorry, no samples matched to sequence runs yet for #{@chosen_lab.lab_name}"
      render :action => 'choose_lab', :locals => {:lab_list => @labs}
      return
    end
   
  end
  
  def update_multi
      
    @debug_list = []
    @files_updated = 0 # for debug
    params[:result_files].each do |id, rfile| # id is key, rfile is hash of file attributes from the form
      @debug_list.push(rfile)
      result_file = ResultFile.find(id)
      #associating result file with list of lanes            
      result_file.seq_lanes = SeqLane.find(rfile[:seq_lanes_ids]) if (rfile[:seq_lanes_ids])
      if (result_file.update_attributes(rfile))
        @files_updated += 1              
      end
    end
    
    if (@files_updated != 0)
      flash.now[:notice] = @files_updated.to_s + " updates were made to Result Files table"
    end
    
    #get result files with associated lanes and samples per lab chosen by admin
    @result_files = ResultFile.find(:all, :include => {:seq_lanes => :sample}, :conditions => {:lab_id => params[:chosen_lab][:id]})
    render :action => 'update_multi_show'    
  end  
  
  def debug
    render :action => :debug  
  end
  
protected
  
  def get_files_from_filesystem(lab_dir_name, lab_id)
    # TODO
    # localize variables
    
    # check if directory exists
    datafile_path = DATAFILES + lab_dir_name + '/' 
    if (File.directory?(datafile_path))
           
      Dir.chdir(datafile_path)
    
      files_list = [];
      file_info = {};
      Dir.foreach('.') {        
        |fn|
        extname = File.extname(fn)[1..-1]
        mime_type = Mime::Type.lookup_by_extension(extname)
        content_type = mime_type.to_s unless mime_type.nil?
        next if ((File.directory?(fn)) || (fn[0].chr == '.')) || (mime_type == 'zip')
         
        file_info = {
          :lab_id => lab_id,
          :document => fn,
          :document_content_type => content_type,
          :document_file_size => File.size(fn),
          :updated_by => current_user.auth_user.id
        }
        files_list.push(file_info)             
      }
      
      Dir.chdir(RAILS_ROOT)    
      return files_list   
    else    
      return nil    
    end
  end
  
  def get_fastqc_files(lab_dir_name)
    
    datafile_path = DATAFILES + lab_dir_name + '/' 
    
    if (File.directory?(datafile_path))
           
      Dir.chdir(datafile_path)
    
      files_dir_list = []
      Dir.foreach('.') { # go through dir looking for fastqc directories       
        |fn|
        next if ((File.directory?(fn)) || (fn[0].chr == '.'))
        fastqc_file = fn
        files_dir_list.push(lab_dir_name + '/' + fastqc_file) if fn.match('fastqc.zip')
      } 
      
      Dir.chdir(RAILS_ROOT) 
      
      return files_dir_list
    else    
      return nil    
    end # if datafile path  
  end
  
  # debug for development only
  def trunc_tables
    ResultFile.connection.execute("TRUNCATE TABLE seq_runs")
    ResultFile.connection.execute("TRUNCATE TABLE seq_lanes")
    ResultFile.connection.execute("TRUNCATE TABLE result_files")
    ResultFile.connection.execute("TRUNCATE TABLE result_files_seq_lanes")
  end
  
end