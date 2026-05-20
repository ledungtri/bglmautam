class TeachersExcelExport
  def initialize(teaching_assignments, year)
    @teaching_assignments = teaching_assignments
    @year = year
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook
    title = "GLV #{@year}-#{@year + 1}"

    workbook.add_worksheet(name: title) do |sheet|
      header_style = sheet.styles.add_style(b: true, alignment: { horizontal: :center })

      sheet.add_row(
        ['STT', 'Lớp', 'Phụ Trách', 'Họ và Tên', 'Tên Ngắn', 'Giới Tính', 'Ngày Sinh', 'Bổn Mạng', 'Điện Thoại', 'Email', 'Số Nhà', 'Đường', 'Phường/Xã', 'Quận/Huyện'],
        style: header_style
      )

      text_style = sheet.styles.add_style(format_code: '@')

      @teaching_assignments.each_with_index do |ta, index|
        teacher = ta.teacher
        sheet.add_row(
          [
            index + 1,
            ta.classroom.name,
            ta.position,
            teacher.name,
            teacher.nickname,
            teacher.gender,
            teacher.date_birth&.strftime('%d/%m/%Y'),
            teacher.named_date,
            teacher.phone,
            teacher.email,
            teacher.street_number,
            teacher.street_name,
            teacher.ward,
            teacher.district
          ],
          types: Array.new(14, :string).unshift(:integer),
          style: [nil, nil, nil, nil, nil, nil, text_style, nil, text_style, nil, nil, nil, nil, nil]
        )
      end
    end

    package.to_stream.read
  end
end
