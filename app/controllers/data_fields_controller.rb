class DataFieldsController < ApplicationController
  before_action :set_parent, :set_schema

  def update
    if @schema
      @parent.data ||= []
      updated = @parent.update_data_field(key, data_field_params)
    end

    respond_to do |format|
      if updated
        flash[:success] = "#{@parent.class} was successfully updated."
      end
      format.html { redirect_to Student.find_by_person_id(@parent.id) }
    end
  end

  private

  def set_schema
    @schema = DataSchema.find_by(key: key, entity: @parent.class.to_s) if @parent
  end

  def set_parent
    if params[:person_id]
      @parent = Person.find(params[:person_id])
    end
  end

  def key
    params[:key]
  end

  def data_field_params
    params.permit(@schema.fields.map{ |f| f['field'] })
  end
end