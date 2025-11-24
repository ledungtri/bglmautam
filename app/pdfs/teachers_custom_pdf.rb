class TeachersCustomPdf < AbstractPdf
  def initialize(teaching_assignments, title_text, page_layout, columns)
    @teaching_assignments = teaching_assignments
    @columns = columns
    @width = page_layout == :landscape ? 800 : 550

    title_text = "#{title_text}\nNăm Học #{@teaching_assignments[0].classroom.long_year}"
    super(page_layout, title_text, '')
  end

  def body
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 80) do
      table line_items, width: @width do
        self.header = true
        self.position = :center
        self.row_colors = %w[e5e3e3 FFFFFF]

        row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)

        column(0).style(align: :center)
        column(0).style(width: 30)
        column(1).style(width: 160)
        column(2).style(width: 60, align: :center)
        column(3).style(width: 60, align: :center)
      end
    end
  end

  def line_items
    [['STT', 'GLV', 'Lớp', 'Phụ Trách'] + @columns] +
      @teaching_assignments.each_with_index.map do |teaching_assignment, index|
        [index + 1, teaching_assignment.teacher.name, teaching_assignment.classroom.name, teaching_assignment.position] + [""] * @columns.length
      end
  end
end
