class EvaluationsPdf < AbstractPdf
  GRADE_NAMES = ['Giữa HK 1', 'Cuối HK 1', 'Giữa HK 2', 'Cuối HK 2'].freeze

  def initialize(classroom)
    @classroom = classroom
    @enrollments = classroom.enrollments
                            .reorder(nil)
                            .includes(:student, :grades, :evaluation, :attendances)
                            .sort_by(&:sort_param)
    title_text = "Nhận Xét & Điểm Số Lớp #{classroom.name}"
    sub_title_text = "Năm Học #{classroom.long_year} - Số Lượng: #{@enrollments.count}"
    super(:landscape, title_text, sub_title_text)
  end

  def body
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 80) do
      @enrollments.group_by(&:result).sort.each do |key, group|
        @group = group
        table line_items do
          self.header = true
          self.position = :center
          self.row_colors = %w[e5e3e3 FFFFFF]

          row(0).style(align: :center, font_style: :bold, height: 25, valign: :center)

          column(0).style(align: :center, width: 20)
          column(1).style(width: 160)
          column(2).style(align: :center, width: 55)
          column(3).style(align: :center, width: 55)
          column(4).style(align: :center, width: 55)
          column(5).style(align: :center, width: 55)
          column(6).style(align: :center, width: 55)
          column(7).style(align: :center, width: 55)
          column(8).style(align: :center, width: 55)
          column(9).style(align: :center, width: 55)
          column(10).style(width: 180)
        end
        bounding_box([bounds.width - 80, cursor], width: 80) do
          text "#{key}: #{group.count}", align: :right
          move_down 8
        end
      end
    end
  end

  def line_items
    headers = ['STT', 'Tên Thánh - Họ và Tên', 'Kết Quả',
               'Giữa HK 1', 'Cuối HK 1', 'Giữa HK 2', 'Cuối HK 2',
               'Hiện Diện', 'Vắng Lễ', 'Vắng Lớp', 'Nhận Xét']
    [headers] + @group.each_with_index.map do |en, index|
      attendances = en.attendances
      attended    = attendances.count { |a| a.status == 'Hiện Diện' }
      mass_absent = attendances.count { |a| a.status == 'Vắng Lễ' }
      absent      = attendances.count - mass_absent - attended

      grades = en.grades.index_by(&:name)
      grade_values = GRADE_NAMES.map { |name| grades[name]&.value }

      [
        index + 1,
        en.student.name,
        en.result,
        *grade_values,
        attended,
        mass_absent,
        absent,
        en.evaluation&.content
      ]
    end
  end
end
