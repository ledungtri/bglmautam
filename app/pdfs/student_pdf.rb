class StudentPdf < Prawn::Document
  def initialize(student)
    super(page_size: 'A4')
    @student = student
    self.font_size = 13
    font_families.update('HongHa' => {
                           normal: Rails.root.join('app/assets/fonts/UVNHongHa_R.TTF'),
                           bold: Rails.root.join('app/assets/fonts/14_13787_UVNHongHa_B.TTF')
                         })
    font 'HongHa'

    text 'Sơ Yếu Lý Lịch', size: 20, align: :center, style: :bold
    text @student.name, size: 15, align: :center, style: :bold
    text "Lớp: #{@student.attendances.last&.cell&.name || '__________________'}", size: 13, align: :center, style: :bold
    move_down 10
    body
    footer
  end

  def body
    table basic do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 100, align: :center)
      column(3).style(width: 220)
    end

    table dates do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 100, align: :center)
      column(3).style(width: 220)
    end

    table parents do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(2).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')

      column(1).style(width: 220)
      column(3).style(width: 100, align: :center)
    end

    table address do
      self.position = :center

      column(0).style(width: 100, align: :right, font_style: :bold, background_color: 'e5e3e3')
      column(1).style(width: 420)
    end

    move_down 10

    return if @student.attendances.empty?

    text 'Hành Trình Thiêng Liêng', size: 20, align: :center, style: :bold

    table process do
      self.position = :center
      row(0).style(font_style: :bold, height: 35, valign: :center, background_color: 'e5e3e3')

      column(0).style(width: 100, align: :center)
      column(1).style(width: 100, align: :center)
      column(2).style(width: 100, align: :center)
    end
  end

  def basic
    [
      ['Tên Thánh', @student.christian_name, 'Họ và Tên', @student.full_name],
      ['Ngày Sinh', @student.date_birth&.strftime('%d-%m-%Y'), 'Nơi Sinh', @student.place_birth]
    ]
  end

  def dates
    [
      ['Rửa Tội', @student.date_baptism&.strftime('%d-%m-%Y'), 'Nơi Rửa Tội', @student.place_baptism],
      ['Rước Lễ', @student.date_communion&.strftime('%d-%m-%Y'), 'Nơi Rước Lễ', @student.place_communion],
      ['Thêm Sức', @student.date_confirmation&.strftime('%d-%m-%Y'), 'Nơi Thêm Sức', @student.place_confirmation],
      ['Tuyên Hứa', @student.date_declaration&.strftime('%d-%m-%Y'), 'Nơi Tuyên Hứa', @student.place_declaration]
    ]
  end

  def parents
    [
      ['Họ Tên Cha', @student.father_name, 'Điện Thoại', @student.father_phone],
      ['Họ Tên Mẹ', @student.mother_name, 'Điện Thoại', @student.mother_phone]
    ]
  end

  def address
    [
      ['Địa Chỉ', @student.address],
      ['Xóm Giáo', @student.area]
    ]
  end

  def process
    [['Năm Học', 'Lớp', 'Kết Quả']] +
      @student.attendances.sort_by { |a| a.cell.year }.map do |attendance|
        [attendance.cell.long_year, attendance.cell .name, attendance.result]
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
