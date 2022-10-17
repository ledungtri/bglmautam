class CustomStudentsPdf < Prawn::Document
  def initialize(cell, title_text, page_layout, columns)
    super(page_size: 'A4', page_layout: page_layout, margin: 20)
    @cell = cell
    @students = cell.students
    @title_text = title_text
    @columns = columns
    @width = page_layout == :landscape ? 800 : 550
    self.font_size = 8

    font_families.update('HongHa' => {
      normal: Rails.root.join('app/assets/fonts/UVNHongHa_R.TTF'),
      bold: Rails.root.join('app/assets/fonts/14_13787_UVNHongHa_B.TTF')
    })
    font 'HongHa'

    title
    move_down 20
    line_items
    footer
  end

  def title
    text "#{@cell.name} - #{@title_text}\nNăm Học #{@cell.long_year}", size: 15, align: :center, style: :bold
  end

  def line_items
    bounding_box([0, cursor], width: bounds.width, height: bounds.height - 80) do
      table line_item_rows, width: @width do
        self.header = true
        self.position = :center
        self.row_colors = %w[e5e3e3 FFFFFF]

        row(0).style(align: :center, font_style: :bold, height: 35, valign: :center)

        column(0).style(align: :center)
        column(0).style(width: 30)
        column(1).style(width: 220)
      end
    end
  end

  def line_item_rows
    [['STT', 'Tên Thánh - Họ và Tên'] + @columns] +
      @students.each_with_index.map do |student, index|
        [index + 1,student.name] + [""] * @columns.length
      end
  end

  def footer
    page_count.times do |i|
      go_to_page(i + 1)
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text 'Ban Giáo Lý Giáo Xứ  Mẫu Tâm', size: 6, align: :right
      end
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text "In ngày: #{Time.zone.now.strftime('%d/%m/%Y')}", size: 6, align: :left
      end
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text "Trang #{i + 1}/#{page_count}", size: 6, align: :center
      end
    end
  end
end
