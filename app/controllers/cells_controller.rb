class CellsController < ApplicationController
  before_action :set_cell, only: %i[show edit update destroy custom_export_view custom_export]
  before_action :auth
  before_action :admin?, only: %i[new create edit update destroy]

  # GET /cells
  # GET /cells.json
  def index
    @cells = Cell.where(year: @current_year).where(grade: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời']).sort_by(&:sort_param)

    respond_to do |format|
      format.html
      format.pdf do
        pdf = CellsPdf.new(@cells)
        send_data pdf.render, filename: "Thống Kê Các Lớp Năm Học #{@cells.first.long_year}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  # GET /cells/1
  # GET /cells/1.json
  def show
    @instructions = @cell.instructions.sort_by(&:sort_param)
    @attendances = @cell.attendances.sort_by(&:sort_param)
    respond_to do |format|
      format.html
      format.xlsx do
        response.headers[
          'Content-Disposition'
        ] = "attachment; filename=#{@cell.name}.xlsx"
      end
      format.pdf do
        if params[:style] == 'teachers_contact'
          pdf = TeachersContactPdf.new(@cell)
          return send_data pdf.render, filename: "Số điện toại GLV.pdf", type: 'application/pdf', disposition: 'inline'
        end

        pdfClass = params[:style] == 'compact' ? CompactStudentsPdf : StudentsPdf
        pdf = pdfClass.new(@attendances, "Danh Sách Lớp #{@cell.name}\nNăm Học #{@cell.long_year}")
        send_data pdf.render, filename: "Danh Sách Lớp #{@cell.name} Năm Học #{@cell.long_year}.pdf", type: 'application/pdf', disposition: 'inline'
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
    @cell.instructions.each(&:destroy)

    @cell.attendances.each(&:destroy)

    @cell.destroy
    respond_to do |format|
      flash[:success] = 'Cell was successfully destroyed.'
      format.html { redirect_to cells_url }
      format.json { head :no_content }
    end
  end

  def students_personal_details
    @cell = Cell.find(params[:cell_id])
    @students = @cell.students.sort_by(&:sort_param)

    respond_to do |format|
      format.html

      format.pdf do
        pdf = StudentsPersonalDetailsPdf.new(@students)
        send_data pdf.render, filename: "Sơ Yếu Lý Lịch Lớp #{@cell.name} Năm Học #{@cell.long_year}.pdf", type: 'application/pdf', disposition: 'inline'
      end
    end
  end

  def cells_custom_export_view
  end

  def cells_custom_export
    @cells = Cell.where(year: @current_year).where(grade: ['Khai Tâm', 'Rước Lễ', 'Thêm Sức', 'Bao Đồng', 'Vào Đời']).sort_by(&:sort_param)
    pdf = CellsCustomPdf.new(@cells, params[:title], params[:page_layout].to_sym, params[:columns].split(','))
    send_data pdf.render, filename: "#{params[:title]}.pdf", type: 'application/pdf', disposition: 'inline'
  end

  def custom_export_view
  end

  def custom_export
    Cell.
    pdf = CustomStudentsPdf.new(params[:title], params[:page_layout].to_sym, params[:columns].split(','))
    send_data pdf.render, filename: "#{@cell} - #{params[:title]}.pdf", type: 'application/pdf', disposition: 'inline'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_cell
    @cell = Cell.find(params[:id] || params[:cell_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def cell_params
    params.require(:cell).permit(:year, :grade, :group, :location)
  end
end
