class SamplesController < ApplicationController
  load_and_authorize_resource
  
  # GET /samples
  def index
    @samples = Sample.userlab(current_user).find(:all, :include => :shipment)
  end
  
  def list_intransit
    @samples = Sample.userlab(current_user).find(:all, :include => :shipment,
                                                       :conditions => "shipments.date_received IS NULL")
  end

  # GET /samples/1
  def show
    @sample = Sample.find(params[:id], :include => :shipment)
  end
  
  def show_sop
    headers["Content-Type"] = "application/msword"
    send_file("#{Sample::SAMPLE_SOP_PATH}") 
  end

  # GET /samples/new
  def new
    @sample = Sample.new(Sample::SAMPLE_DEFAULT)
    @sample.build_shipment(Shipment::SHIPMENT_DEFAULT)
  end
  
  def sample_confirmation
    #@sample = Sample.new(params[:sample])
    @sample = Sample.find(params[:id])
    @sample_confirm = SampleConfirm.new
  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id])
  end

  # POST /samples
  def create
    @sample = Sample.new(params[:sample].merge!(:lab_id => current_user.lab_id))

    respond_to do |format|
      if @sample.save
        format.html { redirect_to(@sample, :notice => 'Sample was successfully created.') }
        format.xml  { render :xml => @sample, :status => :created, :location => @sample }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /samples/1
  def update
    @sample = Sample.find(params[:id])

    respond_to do |format|
      if @sample.update_attributes(params[:sample])
        format.html { redirect_to(@sample, :notice => 'Sample was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @sample.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def update_multi
    params[:sample].each do |id, attributes|
      sample = Sample.find(id)
      sample.update_attributes(attributes) 
    end
    flash[:notice] = 'Sample receipt updated'
    redirect_to samples_path
  end

  # DELETE /samples/1
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy
    redirect_to(samples_url)
  end
  
  def upd_date_recvd
    new_date = (params[:checked_value] == '1' ? Date.today : nil)
    render :update do |page|
      page['sample_' + params[:id] + '_shipment_attributes_date_received'].value = new_date
    end
  end
  
  def auto_complete_for_intestinal_sc_marker
    @svalues = Sample.find(:all, :select => "distinct intestinal_sc_marker",
                           :conditions => ["intestinal_sc_marker LIKE ?", params[:search] + '%'])
    Sample::SC_MARKERS.each do |marker|
      @svalues.push(Sample.new(:intestinal_sc_marker => marker)) if marker[0..(params[:search].length-1)] == params[:search]
    end
    render :inline => "<%= auto_complete_result(@svalues, 'intestinal_sc_marker') %>"
  end
  
  def auto_complete_for_sc_marker_validation_method
    @svalues = Sample.find(:all, :select => "distinct sc_marker_validation_method",
                           :conditions => ["sc_marker_validation_method LIKE ?", params[:search] + '%'])
    Sample::MARKER_VALIDATION.each do |validation|
      @svalues.push(Sample.new(:sc_marker_validation_method => validation)) if validation[0..(params[:search].length-1)] == params[:search]
    end
    render :inline => "<%= auto_complete_result(@svalues, 'sc_marker_validation_method') %>"
  end
  
end
