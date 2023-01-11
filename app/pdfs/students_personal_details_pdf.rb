class StudentsPersonalDetailsPdf < Prawn::Document
  def initialize(students)
    super(page_size: 'A4', margin: 20)
    @students = students
    self.font_size = 8

    font_families.update('HongHa' => {
      normal: Rails.root.join('app/assets/fonts/UVNHongHa_R.TTF'),
      bold: Rails.root.join('app/assets/fonts/14_13787_UVNHongHa_B.TTF')
    })
    font 'HongHa'

    @students.map do |student|
      @student = student
      title
      move_down 20
      body
      footer
      start_new_page(page_size: 'A4', margin: 20)
    end
  end

  def title
    text 'Sơ Yếu Lý Lịch', size: 20, align: :center, style: :bold
    text @student.name, size: 20, align: :center, style: :bold
  end

  def body
    table basic do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 100, align: :center)
      column(3).style(width: 220)
    end
    move_down 20

    table dates do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 100, align: :center)
      column(3).style(width: 220)
    end

    move_down 20

    table parents do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 220)
      column(3).style(width: 100, align: :center)
    end

    move_down 20

    table address do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 220)
      column(3).style(width: 100, align: :center)
    end

    move_down 30

    text 'Hành Trình Thiêng Liêng', size: 20, align: :center, style: :bold
    move_down 10

    table process do
      self.position = :center
      row(0).style(font_style: :bold, height: 35, valign: :center, background_color: 'e5e3e3')

      column(0).style(width: 100, align: :center)
      column(1).style(width: 100, align: :center)
      column(2).style(width: 100, align: :center)
    end
  end

  def basic
    birth = @student.date_birth.strftime('%d-%m-%Y') if @student.date_birth

    [['Tên Thánh', @student.christian_name, 'Họ và Tên', @student.full_name]] +
      [['Ngày Sinh', birth, 'Nơi Sinh', @student.place_birth]]
  end

  def dates
    baptism = @student.date_baptism.strftime('%d-%m-%Y') if @student.date_baptism
    communion = @student.date_communion.strftime('%d-%m-%Y') if @student.date_communion
    confirmation = @student.date_confirmation.strftime('%d-%m-%Y') if @student.date_confirmation
    declaration = @student..date_declaration.strftime('%d-%m-%Y') if @student.date_declaration

    [['Rửa Tội', baptism, 'Nơi Rửa Tội', @student.place_baptism]] +
      [['Rước Lễ', communion, 'Nơi Rước Lễ', @student.place_communion]] +
      [['Thêm Sức', confirmation, 'Nơi Thêm Sức', @student.place_confirmation]] +
      [['Tuyên Hứa', declaration, 'Nơi Tuyên Hứa', @student.place_declaration]]
  end

  def parents
    [['Họ Tên Cha', @student.father_name, 'Điện Thoại Cha', @student.father_phone]] +
      [['Họ Tên Mẹ', @student.mother_name, 'Điện Thoại Mẹ', @student.mother_phone]]
  end

  def address
    [['Địa Chỉ', { content: @student.address, colspan: 3 }]] +
      [['Xóm Giáo', @student.area, 'Điện Thoại Nhà', @student.phone]]
  end

  def process
    [['Năm Học', 'Lớp', 'Kết Quả']] +
      @student.enrollments.sort_by { |enrollment| enrollment.classroom.year }.map do |enrollment|
        [enrollment.classroom.long_year, enrollment.classroom .name, enrollment.result]
      end
  end

  def footer
    bounding_box [bounds.left, bounds.bottom + 8], width: bounds.width do
      text 'Ban Giáo Lý Giáo Xứ  Mẫu Tâm', size: 6, align: :right
    end
    bounding_box [bounds.left, bounds.bottom + 8], width: bounds.width do
      text "In ngày: #{Time.zone.now.strftime('%d/%m/%Y')}", size: 6, align: :left
    end
  end
end
