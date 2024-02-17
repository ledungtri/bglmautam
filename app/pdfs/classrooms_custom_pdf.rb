class ClassroomsCustomPdf < AbstractPdf
  def initialize(classrooms, title_text, page_layout)
    @classrooms = classrooms
    @columns = columns
    @width = page_layout == :landscape ? 800 : 550
    title_text = "#{title_text}\nNăm Học #{@classrooms[0].long_year}"
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
        column(1).style(width: 60)
        column(2).style(width: 100)
      end
    end
  end

  def line_items
    [['STT', 'Lớp', 'Vị Trí'] + @columns] +
    @classrooms.each_with_index.map do |classroom, index|
        [index + 1, classroom.name, classroom.location] + [""] * @columns.length
      end
  end
end
