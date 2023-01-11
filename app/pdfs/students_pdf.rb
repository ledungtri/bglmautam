class StudentsPdf < Prawn::Document
  def initialize(enrollments, title_text)
    super(page_size: 'A4', page_layout: :landscape, margin: 20)
    @enrollments = enrollments
    @title_text = title_text
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
    text @title_text, size: 15, align: :center, style: :bold
    text "Số Lượng: #{@enrollments.count}", size: 10, align: :center
  end

  def line_items
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 80) do
      @enrollments.group_by(&:result).sort.each do |key, group|
        @group = group
        table line_item_rows do
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

  def line_item_rows
    [['STT', 'Họ và Tên', 'Ngày Sinh', 'Địa Chỉ', 'ĐT Cha', 'ĐT Mẹ', 'Lớp', 'Kết Quả']] +
      @group.each_with_index.map do |enrollment, index|
        student = enrollment.student
        [
          index + 1,
          student.name,
          student.date_birth.strftime('%d/%m/%Y'),
          student.address,
          student.father_phone,
          student.mother_phone,
          enrollment.classroom.name,
          enrollment.result
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
