class LineItemsController < ApplicationController
  # GET /line_items
  # GET /line_items.json
  def index
    @line_items = LineItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @line_items }
    end
  end

  # GET /line_items/1
  # GET /line_items/1.json
  def show
    @line_item = LineItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @line_item }
    end
  end

  # GET /line_items/new
  # GET /line_items/new.json
  def new
    @line_item = LineItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line_item }
    end
  end

  # GET /line_items/1/edit
  def edit
    @line_item = LineItem.find(params[:id])
  end

  # POST /line_items
  # POST /line_items.json
  def create
      if params[:add_all] == 'true'
        add_all
      else
        add_single
      end
  end

  def add_single
    @data_file = DataFile.find(params[:data_file_ids])
    @line_item = current_user.line_items.build
    @line_item.data_file= @data_file

    respond_to do |format|
      if @line_item.save
        format.html { redirect_to data_file_path(@data_file),
          notice: 'File was successfully added to cart.' }
        format.js { }
      else
        format.html { redirect_to data_file_path(@data_file),
          notice: 'File could not be added to cart.' }
      end
    end
  end

  def add_all
    params[:data_files_ids[]].each do |file_id|
      data_file = DataFile.find(file_id)
      unless current_user.data_file_in_cart?(data_file)
        @line_item = current_user.line_items.build
        @line_item.data_file= data_file
        @line_item.save
      end
    end
    respond_to do |format|
      format.js { }
    end
  end

  # PUT /line_items/1
  # PUT /line_items/1.json
  def update
    @line_item = LineItem.find(params[:id])

    respond_to do |format|
      if @line_item.update_attributes(params[:line_item])
        format.html { redirect_to @line_item, notice: 'Line item was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @line_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /line_items/1
  # DELETE /line_items/1.json
  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    respond_to do |format|
      format.html { redirect_to line_items_url }
      format.json { head :ok }
    end
  end

   # DELETE /line_items/1
  # DELETE /line_items/1.json
  def download
    @line_item = LineItem.find(params[:id])
    @line_item.destroy

    respond_to do |format|
      format.html { redirect_to line_items_url }
      format.json { head :ok }
    end
  end
end
