class ColumnMappingsController < ApplicationController

  before_filter :authenticate_user!
  set_tab :admin

  def index
    @column_mappings = ColumnMapping.all
  end

  def new
    @column_mappings = []
    5.times { @column_mappings << ColumnMapping.new }
  end

  def create
    errors = []
    @messages = []
    blank = []
    a = 0
    @column_mappings = []
    params[:column_mappings].each_value do |map|
      if !map.values.all?(&:blank?)
        @column_mapping = ColumnMapping.new(map)
        @column_mappings.push(@column_mapping)
        unless @column_mapping.valid?
          @column_mapping.errors.full_messages.each do |err_message|
            @messages << err_message
            errors << "#{a}"
          end
        end
      else
        blank << "#{a}"
      end
      a = a + 1
    end
    if !errors.empty?
      render :action => 'new'
      return
    elsif blank.size == a
      flash[:notice] = "Enter column mapping info and try again"
      redirect_to new_column_mapping_path
      return
    end
    @column_mappings.each do |mapping|
      mapping.save
    end
    flash[:notice] = "Column Mappings added successfully"
    redirect_to column_mappings_path
  end

  def destroy
    @column_mapping = ColumnMapping.find(params[:id])
    @column_mapping.destroy
    redirect_to column_mappings_path, :notice => "The file was successfully deleted"
  end
  
end