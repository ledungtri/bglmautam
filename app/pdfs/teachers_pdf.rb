class TeachersPdf < AbstractPdf
  def initialize(guidances, year)
    @guidances = guidances
    @year = year
    title_text = "Nhân sự phụ trách Giáo dục Đức tin Năm Học #{@year.to_s + ' - ' + (@year + 1).to_s}"
    sub_title_text = "Số Lượng: #{@guidances.count}"
    super(:landscape, title_text, sub_title_text)
  end

  def body
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 50) do
      table line_items do
        self.header = true
        self.position = :center
        self.row_colors = %w[e5e3e3 FFFFFF]

        row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)

        column(0).style(align: :center)
        column(1).style(align: :center)
        column(4).style(align: :center)
        column(5).style(align: :center)
        column(6).style(align: :center)
      end
    end
  end

  def line_items
    [['Lớp', 'Phụ Trách', 'Họ và Tên', 'Ngày Sinh', 'Bổn Mạng', 'Điện Thoại', 'Email']] +
    @guidances.map do |guidance|
        teacher = guidance.teacher
        [
          guidance.classroom.name,
          guidance.position,
          teacher.name,
          teacher.date_birth&.strftime('%d/%m/%Y'),
          teacher.named_date,
          teacher.phone,
          teacher.email
        ]
      end
  end
end
