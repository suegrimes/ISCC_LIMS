class SeqRunsController < ApplicationController
  load_and_authorize_resource
  
  # GET /seq_lanes
  def index
    @seq_runs = SeqRun.find(:all, :include => :seq_lanes, :conditions => set_lab_conditions('seq_lanes') )
  end
  
  # GET /seq_lanes/1
  def show
    @seq_run = SeqRun.find(params[:id], :include => {:seq_lanes => :sample}, :order => 'seq_lanes.lane_nr')
  end
  
  def new
    @seq_run = SeqRun.new(:date_sequenced => Date.today)
    @samples        = Sample.userlab(current_user).find(:all, :order => 'samples.lab_id')
                                   
    # Populate seq lanes for each sample found above
    @seq_lanes = []
    @samples.each_with_index do |sample, i|
      @seq_lanes[i] = SeqLane.new(:sample_id => sample.id)
    end     
    
    render :action => 'new'
  end
  
  # GET /seq_lanes/1/edit
  def edit
    @seq_run = SeqRun.find(params[:id], :include => {:seq_lanes => :sample}, :order => 'seq_lanes.lane_nr')   
    @partial_flowcell = (@seq_run.seq_lanes.size < SeqRun::NR_LANES ? 'Y' : 'N')
  end

  # POST /seq_lanes
  def create 
    # Builds flow_lanes for all lanes (even blank lane#s).  Need to include blank
    # lanes so that all samples show with appropriate lanes (or blank)
    # when error condition is encountered
    @seq_run = SeqRun.new(params[:seq_run])
   
    lane_nrs = non_blank_lane_nrs(non_blank_lanes(params[:seq_lane]))  # Array of lane#s which are non-blank
    lanes_required  = SeqRun::NR_LANES
      
    # Validation check to ensure lanes 1-8 entered, and no duplicate lanes
    lane_errors = validate_lane_nrs(params[:seq_lane], 'create', lanes_required)
    
    if lane_errors[0] > 0
      flash[:error] = "ERROR - #{lane_errors[1]}"
      prepare_for_render_new(params)
      render :action => 'new'
        
    else 
      @seq_run.build_seq_lanes(params[:seq_lane])
      if @seq_run.save
        flash[:notice] = 'Sequencing run was successfully created'
        redirect_to(@seq_run)
     
      else
        flash[:error] = 'ERROR - Unable to create sequencing run'
        prepare_for_render_new(params)
        render :action => 'new'
      end
    end
  end

  # PUT /seq_lanes/1
  def update
    @seq_run = SeqRun.find(params[:id])
    
    lane_errors = validate_lane_nrs(params[:seq_run][:seq_lanes_attributes], 'update', params[:lane_count].to_i)
 
    if lane_errors[0] > 0
      flash[:error] = "ERROR - #{lane_errors[1]}"
      render :action => 'edit'
      #render :action => 'debug'
      
    elsif @seq_run.update_attributes(params[:seq_run])
      flash[:notice] = 'Sequencing run was successfully updated'
      redirect_to(@seq_run) 
      #render :action => 'debug'
      
    else
      flash[:error] = 'ERROR - Unable to update sequencing run'
      render :action => "edit"
    end
  end

  # DELETE /seq_lanes/1
  def destroy
    # make this an admin only function in production
    @seq_run = SeqRun.find(params[:id])
    @seq_run.destroy
    redirect_to(seq_run_url) 
  end
  
protected 
  def prepare_for_render_new(params)
    # Need to recreate sample rows, using lanes[:sample_id]
    @samples = []
    @seq_lanes = []
    params[:seq_lane].each do |lane|
      @seq_lanes.push(SeqLane.new(lane))
      @samples.push(Sample.find_by_id(lane[:sample_id])) 
    end
  end

  def validate_lane_nrs(lanes, create_or_update, lanes_required = SeqRun::NR_LANES)
    errno = 0
    
    if create_or_update == 'create'    
      lanes_nb = non_blank_lanes(lanes)   
      lane_nrs = non_blank_lane_nrs(lanes_nb)
      
    else # create_or_update == update
      lanes_nb = non_blank_lanes(lanes) 
      errno = 4 if lanes_nb.size != lanes_required
      
      lane_nrs = non_blank_lane_nrs(lanes_nb)
      errno = 5 if lane_nrs.size != lanes_required
    end
    
    case errno
      when 4
        return [errno, "Lane number cannot be blank - cannot add or delete sample/lanes after sequencing run created"]
      when 5
        return [errno, "Lane number must be integer - cannot assign a sample to multiple lanes, after sequencing run creation"]
      else
        return check_for_lane_errors(lane_nrs.collect{|lane| lane.to_i}, lanes_required)
    end  
  end
  
  def check_for_lane_errors(lane_nrs, lanes_required)
    nr_entered_lanes = lane_nrs.size
    nr_unique_lanes  = lane_nrs.uniq.size
    
    if nr_entered_lanes != lanes_required
      errno  = 1
      errmsg = "Must have exactly #{lanes_required} lanes - #{nr_entered_lanes} were assigned"
      
    elsif nr_unique_lanes != lanes_required
      errno  = 2
      errmsg = "One or more lane numbers assigned multiple times"
    
    elsif (lane_nrs.min < 1 || lane_nrs.max > SeqRun::NR_LANES)
      errno = 3
      errmsg = "Lane numbers must be integers between 1 and #{SeqRun::NR_LANES}"
      
    else
      errno = 0
      errmsg = ''
    end
    
    return [errno, errmsg]
  end
  
  def non_blank_lanes(lanes)
    if lanes.is_a? Array
      lanes.reject{|lane| lane[:lane_nr].blank?} 
    else  #Hash
      lanes.reject{|lane_id, lane_attrs| lane_attrs[:lane_nr].blank?}
    end
  end
  
  def non_blank_lane_nrs(nb_lanes)
    if nb_lanes.is_a? Array
      nb_lanes.collect{|lane| lane[:lane_nr].split(',')}.flatten
    else  # Hash
      nb_lanes.collect{|lane_id, lane_attrs| lane_attrs[:lane_nr].split(',')}.flatten
    end
  end
  
end 