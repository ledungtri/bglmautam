class CellsController < ApplicationController
  before_action :set_cell, only: [:show, :edit, :update, :destroy]
  before_action :auth 

  # GET /cells
  # GET /cells.json
  def index
    @cells = Cell.where(year: @current_year).where(grade: ["Khai Tâm", "Rước Lễ", "Thêm Sức", "Bao Đồng"]).sort_by {|c| c.sort_param}
    
    respond_to do |format|
      format.html
      format.pdf do 
        pdf = CellsPdf.new(@cells)
        send_data pdf.render , filename: "Thống Kê Các Lớp Năm Học #{@cells.first.long_year}.pdf", type: "application/pdf", disposition: "inline"
      end
    end
  end

  # GET /cells/1
  # GET /cells/1.json
  def show
    @teachers = @cell.teachers
    
    
    @dang_hoc = Array.new
    @len_lop = Array.new
    @hoc_lai = Array.new
    @nghi_luon = Array.new
    @chuyen_xu = Array.new
    
    @students = @cell.students
    @students = @students.sort_by { |s| s.sort_param }
    
    @students.each do |student|
      result = student.result(@cell)
      case
      when result == "Đang Học"
        @dang_hoc.push(student)
      when result == "Lên Lớp"
        @len_lop.push(student)
      when result == "Học Lại"
        @hoc_lai.push(student)
      when result == "Nghỉ Luôn"
        @nghi_luon.push(student)
      when result == "Chuyển Xứ"
        @chuyen_xu.push(student)
      end
    end
    
    @arrays = [@hoc_lai, @nghi_luon, @chuyen_xu, @dang_hoc, @len_lop]
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = StudentsPdf.new(@arrays, @cell)
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
        format.html { redirect_to @cell, notice: 'Cell was successfully created.' }
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
        format.html { redirect_to @cell, notice: 'Cell was successfully updated.' }
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
      format.html { redirect_to cells_url, notice: 'Cell was successfully destroyed.' }
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
