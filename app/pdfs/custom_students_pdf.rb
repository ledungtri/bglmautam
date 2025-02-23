class CustomStudentsPdf < AbstractPdf
  def initialize(classroom, title_text, page_layout, columns, current_students_only)
    @classroom = classroom
    @enrollments = classroom.enrollments
    current_students_only = ActiveModel::Type::Boolean.new.cast(current_students_only)
    @enrollments = @enrollments.where(result: 'Đang Học') if current_students_only
    @enrollments = @enrollments.sort_by(&:sort_param)
    @columns = columns
    @width = page_layout == :landscape ? 800 : 550
    title_text = "#{@classroom.name} - #{title_text}\nNăm Học #{@classroom.long_year}"
    super(page_layout, title_text, '')
  end

  def body
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 80) do
      table line_item_rows, width: @width do
        self.header = true
        self.position = :center
        self.row_colors = %w[e5e3e3 FFFFFF]

        row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)

        column(0).style(align: :center)
        column(0).style(width: 30)
        column(1).style(width: 200)
      end
    end
  end

  def line_item_rows
    [['STT', 'Tên Thánh - Họ và Tên'] + @columns] +
      @enrollments.each_with_index.map do |enrollment, index|
        [index + 1, enrollment.student.name] + [""] * @columns.length
      end
  end
end
