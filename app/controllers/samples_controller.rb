class SamplesController < ApplicationController
  # GET /samples
  # GET /samples.xml
  def index
    @samples = Sample.lab(current_user).find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @samples }
    end
  end

  # GET /samples/1
  # GET /samples/1.xml
  def show
    begin
      @sample = Sample.lab(current_user).find(params[:id])
    rescue 
      flash[:error] = "ERROR: Sample not found, id=#{params[:id]}"
      redirect_to samples_path
    end    
  end

  # GET /samples/new
  # GET /samples/new.xml
  def new
    @sample = Sample.new(Sample::SAMPLE_DEFAULT)
    @sample.build_shipment(Shipment::SHIPMENT_DEFAULT)

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @sample }
    end
  end

  # GET /samples/1/edit
  def edit
    begin
      @sample = Sample.lab(current_user).find(params[:id]) 
    rescue 
      flash[:error] = "ERROR: Sample not found, id=#{params[:id]}"
      redirect_to samples_path
    end 
  end

  # POST /samples
  # POST /samples.xml
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
  # PUT /samples/1.xml
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

  # DELETE /samples/1
  # DELETE /samples/1.xml
  def destroy
    @sample = Sample.find(params[:id])
    @sample.destroy

    respond_to do |format|
      format.html { redirect_to(samples_url) }
      format.xml  { head :ok }
    end
  end
end
