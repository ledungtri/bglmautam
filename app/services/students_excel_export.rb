class StudentsExcelExport
  def initialize(enrollments, title)
    @enrollments = enrollments.sort_by(&:sort_param)
    @title = title
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: @title.truncate(31)) do |sheet|
      header_style = sheet.styles.add_style(b: true, alignment: { horizontal: :center })

      sheet.add_row(
        [
          'STT',
          'Tên Thánh', 'Họ và Tên', 'Ngày Sinh', 'Nơi Sinh', 'Giới Tính',
          'Rửa Tội', 'Nơi Rửa Tội',
          'Rước Lễ', 'Nơi Rước Lễ',
          'Thêm Sức', 'Nơi Thêm Sức',
          'Tuyên Hứa', 'Nơi Tuyên Hứa',
          'Tên Thánh Cha', 'Họ và Tên Cha', 'ĐT Cha',
          'Tên Thánh Mẹ', 'Họ và Tên Mẹ', 'ĐT Mẹ',
          'Số Nhà', 'Đường', 'Phường/Xã', 'Quận/Huyện', 'Xóm Giáo',
          'Lớp', 'Kết Quả'
        ],
        style: header_style
      )

      text_style = sheet.styles.add_style(format_code: '@')

      @enrollments.each_with_index do |enrollment, index|
        student = enrollment.student
        sheet.add_row(
          [
            index + 1,
            student.christian_name, student.full_name,
            student.date_birth&.strftime('%d/%m/%Y'), student.place_birth, student.gender,
            student.date_baptism&.strftime('%d/%m/%Y'), student.place_baptism,
            student.date_communion&.strftime('%d/%m/%Y'), student.place_communion,
            student.date_confirmation&.strftime('%d/%m/%Y'), student.place_confirmation,
            student.date_declaration&.strftime('%d/%m/%Y'), student.place_declaration,
            student.father_christian_name, student.father_full_name, student.father_phone,
            student.mother_christian_name, student.mother_full_name, student.mother_phone,
            student.street_number, student.street_name, student.ward, student.district, student.area,
            enrollment.classroom.name, enrollment.result
          ],
          types: Array.new(28, :string).unshift(:integer),
          style: [
            nil,
            nil, nil, nil, nil, nil, text_style,
            nil, nil, nil, nil, nil, nil, nil, nil,
            nil, nil, text_style,
            nil, nil, text_style,
            nil, nil, nil, nil, nil,
            nil, nil
          ]
        )
      end
    end

    package.to_stream.read
  end
end
