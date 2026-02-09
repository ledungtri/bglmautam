class TeachersContactPdf < Prawn::Document
  def initialize(classroom)
    super(page_size: 'A4', info: { Title: "SĐT GLV #{classroom.name}" })
    self.font_size = 11
    font_families.update('HongHa' => {
      normal: Rails.root.join('app/assets/fonts/UVNHongHa_R.TTF'),
      bold: Rails.root.join('app/assets/fonts/14_13787_UVNHongHa_B.TTF')
    })
    font 'HongHa'

    title = "<font size='18'><b>#{classroom.name}</b></font>"

    body = classroom.teaching_assignments.sort_by(&:sort_param).reduce('') do |content, teaching_assignment|
      content += "<b>#{teaching_assignment.position}</b>: #{teaching_assignment.teacher.name}\n<b>SĐT</b>: #{teaching_assignment.teacher.phone}\n"
      content
    end

    (classroom.teaching_assignments.length >= 3 ? 4 : 5).times.each do
      table [[title, '', title]] + [[body, '', body]] do
        self.position = :center
        self.width = 550
        self.cells.border_width = 0
        self.cell_style = { inline_format: true }
        self.before_rendering_page do |page|
          page.row(0).border_top_width = 1
          page.row(-1).border_bottom_width = 1
          page.column(0).border_left_width = 1
          page.column(0).border_right_width = 1
          page.column(1).border_top_width = 0
          page.column(1).border_bottom_width = 0
          page.column(-1).border_left_width = 1
          page.column(-1).border_right_width = 1
        end

        row(0).style(align: :center)
        row(0).style(align: :center)
        row(1).style(align: :left)
      end

      move_down 20
    end
  end
end