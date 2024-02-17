class ClassroomsPdf < AbstractPdf
  def initialize(classrooms)
    @classrooms = classrooms
    title_text = "Thống Kê Các Lớp Năm Học #{@classrooms.first.long_year}"
    sub_title_text = "Số Lượng: #{@classrooms.count}"
    super(:portrait, title_text, sub_title_text)
  end

  def body
    table line_items do
      self.header = true
      self.position = :center
      self.row_colors = %w[e5e3e3 FFFFFF]

      row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)
      column(0..9).style(align: :center)
      column(3..9).style(width: 55)
    end
  end

  def line_items
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
end
