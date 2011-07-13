class ResultFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @labs = Lab.find(:all, :order => :lab_name)    
  end
  
  def check_chosen_lab
    @labs = Lab.find(:all, :order => :lab_name)
    @chosen_lab_id = params[:lab][:id] if (!params[:lab][:id].blank?) 
    if (params[:lab][:id].blank?)
       flash[:error] = 'Choose Lab with Result Files'
       render :action => 'index'
    else
      redirect_to :action => 'link_multi', :lab_id => @chosen_lab_id
    end
  end
  
  def link_multi

    #ResultFile.connection.execute("TRUNCATE TABLE result_files")
    
  # TODO
  # add debug for new files
  # in the save loop, put condition for if no files in documents variable?
 
  # query linked table
  # query results_files
  # if result_file already in linked table:
  ## display as checked 
  ## else display as unchecked
    
  # localize variables
  # take out unneeded variables
  # some handy code examples from Sue:
      # result_file = ResultFile.find(params[:result_file][:id])
      # result_file.update_attributes(params[:result_file])
      # result_file.samples = Sample.find(params[:result_file][:sample_ids])
      # result_file.save      
  # also see her mail of 6/22
    
    # temporary until user edit features are in place
    #ResultFile.connection.execute("TRUNCATE TABLE result_files")
    
    @lab = Lab.find_by_id(params[:lab_id])
    lab_dir_name = @lab.lab_name.downcase
    lab_dir_name = lab_dir_name.gsub!(/ /, '_') if lab_dir_name.match(/\s/) 
       
    @results_on_filesystem = get_files_from_filesystem(lab_dir_name, @lab.id)
    
    @result_files_before_save = ResultFile.find(:all, :conditions => {:lab_id => @lab.id})
    @documents = @result_files_before_save.collect(&:document) if (!@result_files_before_save.blank?)

=begin
    @exist_in_db = []; @new_files = [];
    files_saved = 0
    @results_on_filesystem.each do |file_info|   
      # check if file is already in the table
      unless (documents.include?(file_info[:document]))
        @new_files.push(file_info[:document])
        result_file = ResultFile.new(file_info)
        if result_file.save
          files_saved += 1           
        end # if
      end # unless
    end # each

    if files_saved != 0 
      flash[:notice] = 'Success! ' + files_saved.to_s + ' new Result files saved'
    else
      flash[:error] = 'No new result files to save'
    end
        
    
    
    @labs = Lab.find(:all, :order => :lab_name)
    @result_files = ResultFile.find(:all, :conditions => {:lab_id => @chosen_lab_id})
    @samples = Sample.find(:all)     
=end    
    #render :action => 'link_multi'
    
  end
    
  def debug
    render :action => :debug  
  end
  
protected
  
  def get_files_from_filesystem(dir_name, lab_id)
    # TODO
    # localize variables
    
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
          :lab_id => lab_id,
          :document => fn,
          :document_content_type => content_type,
          :document_file_size => File.size(fn),
          :updated_by => current_user.auth_user.name
        }

        @files_list.push(file_info) if (fn[0].chr != '.')                
    }
    
    Dir.chdir(RAILS_ROOT)
    return @files_list
    
  end
  
end