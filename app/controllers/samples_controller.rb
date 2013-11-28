class SamplesController < ApplicationController
  load_and_authorize_resource
  
  autocomplete :sample, :strain
  
  # GET /samples
  def index
    @samples = Sample.find_and_group_by_lab(current_user)
  end
  
  def list_intransit
    @samples = Sample.userlab(current_user).includes(:shipment).where('shipments.date_received IS NULL').all
  end

  # GET /samples/1
  def show
    @sample = Sample.find(params[:id]).includes(:shipment)
  end
  
  def show_sop
    headers["Content-Type"] = "application/msword"
    send_file("#{Sample::SAMPLE_SOP_PATH}") 
  end

  # GET /samples/new
  def new
    @sample = Sample.new(Sample::SAMPLE_DEFAULT)
  end
  
  def shipment_confirm
    @sample = Sample.find(params[:id]).includes(:shipment)
    if !@sample.shipment
      checkbox_flags = {:confirm_nr_cells => (@sample.cells_lt_min ? 'N' : 'Y')}
      @sample.build_shipment(Shipment::SHIPMENT_DEFAULT.merge!checkbox_flags)
    end
  end
  
  def sample_ship
    @sample = Sample.find(params[:id]).includes(:shipment)
    if !@sample.shipment
      checkbox_flags = {:confirm_nr_cells => (@sample.cells_lt_min ? 'N' : 'Y')}
      @sample.build_shipment(Shipment::SHIPMENT_DEFAULT.merge!checkbox_flags)
    end
  end
  
#  def ship_dtls
#    @sample = Sample.find(params[:id])
#    render :update do |page|
#      page.replace_html 'shipment', :partial => 'shipment_form', :locals => {:sample => @sample}
#    end
#  end

  # GET /samples/1/edit
  def edit
    @sample = Sample.find(params[:id]).includes(:shipment)
  end

  # POST /samples
  def create
    @sample = Sample.new(params[:sample].merge!(:lab_id => current_user.lab_id))
    if @sample.save
      redirect_to :action => :shipment_confirm, :id => @sample.id
    else
      render :action => "new"
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
  
  # TODO
  # crack open attributes to see what it is gathering
  # it appears from the debug that the shipping id is getting written to the shipment table, 
  # but not the date_received
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
  
  #def auto_complete_for_strain
  def autocomplete_sample_strain
    @svalues = Sample.select('distinct strain').where('strain LIKE ?', params[:term] + '%').all
    #render :inline => "<%= auto_complete_result(@svalues, 'strain') %>"
    list = @svalues.map {|sv| Hash[ id: sv.id, label: sv.strain, name: sv.strain]}
    render json: list
  end
  
  def auto_complete_for_intestinal_sc_marker
    @svalues = Sample.select('distinct intestinal_sc_marker').where('intestinal_sc_marker LIKE ?', params[:search] + '%').all
    Sample::SC_MARKERS.each do |marker|
      @svalues.push(Sample.new(:intestinal_sc_marker => marker)) if marker[0..(params[:search].length-1)] == params[:search]
    end
    render :inline => "<%= auto_complete_result(@svalues, 'intestinal_sc_marker') %>"
  end
  
  def auto_complete_for_sc_marker_validation_method
    @svalues = Sample.select('distinct sc_marker_validation_method').where('sc_marker_validation_method LIKE ?', params[:search] + '%').all
    Sample::MARKER_VALIDATION.each do |validation|
      @svalues.push(Sample.new(:sc_marker_validation_method => validation)) if validation[0..(params[:search].length-1)] == params[:search]
    end
    render :inline => "<%= auto_complete_result(@svalues, 'sc_marker_validation_method') %>"
  end
 
end
