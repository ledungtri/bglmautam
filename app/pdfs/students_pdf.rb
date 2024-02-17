class StudentsPdf < AbstractPdf
  def initialize(enrollments, title_text)
    @enrollments = enrollments
    sub_title_text = "Số Lượng: #{@enrollments.count}"
    super(:landscape, title_text, sub_title_text)
  end

  def body
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 80) do
      @enrollments.group_by(&:result).sort.each do |key, group|
        @group = group
        table line_items do
          self.header = true
          self.position = :center
          self.row_colors = %w[e5e3e3 FFFFFF]

          row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)

          column(0).style(align: :center)
          column(1).style(width: 220)
          column(2).style(width: 60, align: :center)
          column(3).style(width: 250)
          column(4).style(width: 60, align: :center)
          column(5).style(width: 60, align: :center)
          column(6).style(width: 60, align: :center)
          column(7).style(width: 60, align: :center)
        end
        bounding_box([bounds.width - 60, cursor], width: 60) do
          text "#{key}: #{group.count}", align: :center
          move_down 10
        end
      end
    end
  end

  def line_items
    [['STT', 'Họ và Tên', 'Ngày Sinh', 'Địa Chỉ', 'ĐT Cha', 'ĐT Mẹ', 'Lớp', 'Kết Quả']] +
      @group.each_with_index.map do |enrollment, index|
        student = enrollment.student
        [
          index + 1,
          student.name,
          student.date_birth&.strftime('%d/%m/%Y'),
          student.address,
          student.father_phone,
          student.mother_phone,
          enrollment.classroom.name,
          enrollment.result
        ]
      end
  end
end
