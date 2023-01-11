class ClassroomsPdf < Prawn::Document
  def initialize(classrooms)
    super(page_size: 'A4', margin: 20)
    @classrooms = classrooms
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
    text "Thống Kê Các Lớp Năm Học #{@classrooms.first.long_year}", align: :center, size: 15, style: :bold
    text "Số Lượng: #{@classrooms.count}", align: :center, size: 10
  end

  def line_items
    table line_item_rows do
      self.header = true
      self.position = :center
      self.row_colors = %w[e5e3e3 FFFFFF]

      row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)
      column(0..9).style(align: :center)
      column(2..9).style(width: 55)
    end
  end

  def line_item_rows
    [['STT', 'Tên Lớp', 'Vị Trí', 'Tổng Số', 'Nghỉ Luôn', 'Chuyển Xứ', 'Đang Học', 'Lên Lớp', 'Dự Thính', 'Học Lại']] +
      @classrooms.map do |classroom|
        [
          @classrooms.index(classroom) + 1,
          classroom.name,
          classroom.location,
          classroom.enrollments.count,
          classroom.enrollments.where(result: 'Nghỉ Luôn').count,
          classroom.enrollments.where(result: 'Chuyển Xứ').count,
          classroom.enrollments.where(result: 'Đang Học').count,
          classroom.enrollments.where(result: 'Lên Lớp').count,
          classroom.enrollments.where(result: 'Dự Thính').count,
          classroom.enrollments.where(result: 'Học Lại').count
        ]
      end +
      [[
         '',
         'Tổng Số',
         '',
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.count },
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.where(result: 'Nghỉ Luôn').count },
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.where(result: 'Chuyển Xứ').count },
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.where(result: 'Đang Học').count },
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.where(result: 'Lên Lớp').count },
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.where(result: 'Dự Thính').count },
         @classrooms.inject(0) { |sum, classroom| sum + classroom.enrollments.where(result: 'Học Lại').count }
      ]]
  end

  def footer
    bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
      text 'Ban Giáo Lý Giáo Xứ  Mẫu Tâm', size: 6, align: :right
    end
    bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
      text "In ngày: #{Time.zone.now.strftime('%d/%m/%Y')}", size: 6, align: :left
    end
  end
end
