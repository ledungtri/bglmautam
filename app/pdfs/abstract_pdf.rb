class AbstractPdf < Prawn::Document
  def initialize(page_layout, title_text, sub_title_text)
    @title_text = title_text
    @sub_title_text = sub_title_text

    super(page_size: 'A4', page_layout: page_layout, margin: 20)
    self.font_size = 8

    font_families.update('HongHa' => {
      normal: Rails.root.join('app/assets/fonts/UVNHongHa_R.TTF'),
      bold: Rails.root.join('app/assets/fonts/14_13787_UVNHongHa_B.TTF')
    })
    font 'HongHa'

    title
    sub_title
    move_down 5
    body
    footer
  end

  def title
    text @title_text, size: 15, align: :center, style: :bold
  end

  def sub_title
    text @sub_title_text, size: 8, align: :center
  end

  def body
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
