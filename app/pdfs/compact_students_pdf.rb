class CompactStudentsPdf < AbstractPdf

  def initialize(enrollments, title_text)
    @enrollments = enrollments
    @last_year = @enrollments.first.classroom.year - 1
    sub_title_text = "Số Lượng: #{@enrollments.count}"
    super(:portrait, title_text, sub_title_text)
  end

  def body
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 78) do
      table line_items do
        self.header = true
        self.position = :center
        self.row_colors = %w[e5e3e3 FFFFFF]

        row(0).style(align: :center, font_style: :bold, valign: :center)

        column(0).style(align: :center)
        column(1).style(width: 220)
        column(2).style(width: 100, align: :center)
        column(3).style(width: 100, align: :center)
        column(4).style(width: 100, align: :center)
      end
    end
  end

  def line_items
    [['STT', 'Tên Thánh - Họ và Tên', 'Ngày Sinh', 'Lớp Năm Ngoái', 'Kết Quả']] +
      @enrollments.each_with_index.map do |enrollment, index|
        student = enrollment.student
        last_enrollment = student.enrollments.for_year(@last_year).take
        [
          index + 1,
          student.name,
          student.date_birth&.strftime('%d/%m/%Y'),
          last_enrollment&.classroom&.name,
          last_enrollment&.result
        ]
      end
  end
end
