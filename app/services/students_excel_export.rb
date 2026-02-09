class StudentsExcelExport
  def initialize(classroom)
    @classroom = classroom
    @enrollments = classroom.enrollments.sort_by(&:sort_param)
  end

  def generate
    package = Axlsx::Package.new
    workbook = package.workbook

    workbook.add_worksheet(name: @classroom.name) do |sheet|
      header_style = sheet.styles.add_style(b: true, alignment: { horizontal: :center })

      sheet.add_row(
        ['STT', 'Họ và Tên', 'Ngày Sinh', 'Địa Chỉ', 'ĐT Cha', 'ĐT Mẹ', 'Kết Quả'],
        style: header_style
      )

      text_style = sheet.styles.add_style(format_code: '@')

      @enrollments.each_with_index do |enrollment, index|
        student = enrollment.student
        sheet.add_row([
          index + 1,
          student.name,
          student.date_birth&.strftime('%d/%m/%Y'),
          student.address,
          student.father_phone,
          student.mother_phone,
          enrollment.result
        ], types: [:integer, :string, :string, :string, :string, :string, :string],
           style: [nil, nil, nil, nil, text_style, text_style, nil])
      end
    end

    package.to_stream.read
  end
end
