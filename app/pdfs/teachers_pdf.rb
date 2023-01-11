class TeachersPdf < Prawn::Document
  def initialize(guidances, year)
    super(page_size: 'A4', page_layout: :landscape, margin: 20)
    @guidances = guidances
    @year = year
    self.font_size = 8

    font_families.update('HongHa' => {
      normal: Rails.root.join('app/assets/fonts/UVNHongHa_R.TTF'),
      bold: Rails.root.join('app/assets/fonts/14_13787_UVNHongHa_B.TTF')
    })
    font 'HongHa'

    title
    move_down 20
    line_items
    footer
  end

  def title
    text "Nhân sự phụ trách Giáo dục Đức tin Năm Học #{@year.to_s + ' - ' + (@year + 1).to_s}", size: 15, align: :center, style: :bold
    text "Số Lượng: #{@guidances.count}", size: 10, align: :center
  end

  def line_items
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 50) do
      table line_item_rows do
        self.header = true
        self.position = :center
        self.row_colors = %w[e5e3e3 FFFFFF]

        row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)

        column(0).style(align: :center)
        column(1).style(align: :center, width: 60)
        column(2).style(align: :center, width: 60)
        column(5).style(align: :center)
        column(7).style(align: :center)
      end
    end
  end

  def line_item_rows
    [['STT', 'Lớp', 'Phụ Trách', 'Họ và Tên', 'Ngày Sinh', 'Bổn Mạng', 'Email', 'Điện Thoại']] +
    @guidances.each_with_index.map do |guidance, index|
        teacher = guidance.teacher
        [
          index + 1,
          guidance.cell.name,
          guidance.position,
          teacher.name,
          teacher.date_birth.strftime('%d/%m/%Y'),
          teacher.named_date,
          teacher.email,
          teacher.phone
        ]
      end
  end

  def footer
    page_count.times do |i|
      go_to_page(i + 1)
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text 'Ban Giáo Lý Giáo Xứ  Mẫu Tâm', size: 6, align: :right
      end
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text "In ngày: #{Time.zone.now.strftime('%d/%m/%Y')}", size: 6, align: :left
      end
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text "Trang #{i + 1}/#{page_count}", size: 6, align: :center
      end
    end
  end
end
