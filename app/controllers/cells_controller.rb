class CellsController < ApplicationController
  before_action :set_cell, only: [:show, :edit, :update, :destroy]
  before_action :auth 
  before_action :isAdmin, only: [:new, :create, :edit, :update, :destroy]

  # GET /cells
  # GET /cells.json
  def index
    @cells = Cell.where(year: @current_year).sort_by {|c| c.sort_param}
    # TODO: add isClass field to cell
    
    respond_to do |format|
      format.html
      format.pdf do 
        pdf = CellsPdf.new(@cells)
        send_data pdf.render , filename: "Thống Kê Các Lớp Năm Học #{@cells.first.long_year}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  def all
    @cells = Cell.all
  end

  # GET /cells/1
  # GET /cells/1.json
  def show
    @instructions = @cell.instructions
    @attendances = @cell.attendances
    
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=#{@cell.name}.xlsx"
      end
      format.pdf do
        pdf = StudentsPdf.new(@attendances, @cell)
       send_data pdf.render, filename: "Danh Sách Lớp #{@cell.name} Năm Học #{@cell.long_year}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  # GET /cells/new
  def new
    @cell = Cell.new
  end

  # GET /cells/1/edit
  def edit
  end

  # POST /cells
  # POST /cells.json
  def create
    @cell = Cell.new(cell_params)

    respond_to do |format|
      if @cell.save
        flash[:success] = 'Cell was successfully created.'
        format.html { redirect_to @cell }
        format.json { render :show, status: :created, location: @cell }
      else
        format.html { render :new }
        format.json { render json: @cell.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cells/1
  # PATCH/PUT /cells/1.json
  def update
    respond_to do |format|
      if @cell.update(cell_params)
        flash[:success] = 'Cell was successfully updated.'
        format.html { redirect_to @cell }
        format.json { render :show, status: :ok, location: @cell }
      else
        format.html { render :edit }
        format.json { render json: @cell.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cells/1
  # DELETE /cells/1.json
  def destroy
    @cell.destroy
    respond_to do |format|
      flash[:success] = 'Cell was successfully destroyed.'
      format.html { redirect_to cells_url }
      format.json { head :no_content }
    end
  end
  
  def attendance_check
    @cell = Cell.find(params[:cell_id])
    @students = @cell.students.sort_by{|student| student.sort_param}
    
    respond_to do |format|
      format.html
      
      format.pdf do
        pdf = AttendanceCheckPdf.new(@students)
        send_data pdf.render, filename: "Điểm Danh Lớp #{@cell.name} Năm Học #{@cell.long_year}.pdf", type: "application/pdf", disposition: "inline"
      end
    end

  end

  def summary
    @cell = Cell.find(params[:cell_id])
    @instructions = @cell.instructions.order(:position)
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cell
      @cell = Cell.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cell_params
      params.require(:cell).permit(:year, :grade, :group, :location)
    end

end
