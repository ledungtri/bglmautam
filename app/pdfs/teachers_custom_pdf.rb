class TeachersCustomPdf < AbstractPdf
  def initialize(guidances, title_text, page_layout, columns)
    @guidances = guidances
    @columns = columns
    @width = page_layout == :landscape ? 800 : 550

    title_text = "#{title_text}\nNăm Học #{@guidances[0].classroom.long_year}"
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
      @guidances.each_with_index.map do |guidance, index|
        [index + 1, guidance.teacher.name, guidance.classroom.name, guidance.position] + [""] * @columns.length
      end
  end
end
