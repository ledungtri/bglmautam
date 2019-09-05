class CellsPdf < Prawn::Document
   def initialize (cells) 
      super(:page_size => "A4", :margin => 20)
      @cells = cells
      self.font_size = 8
      
      font_families.update("HongHa" => {
         :normal => Rails.root.join("app/assets/fonts/UVNHongHa_R.TTF"),
         :bold => Rails.root.join("app/assets/fonts/14_13787_UVNHongHa_B.TTF"),
      })
      font "HongHa"
      
      title
      move_down 20
      line_items
      footer
   end
   
   def title 
      text "Thống Kê Các Lớp Năm Học #{@cells.first.long_year}", :align => :center, :size => 15, :style => :bold
      text "Số Lượng: #{@cells.count}", :align => :center, :size => 10
   end
   
   def line_items
      table line_item_rows do
         self.header = true
         self.position = :center
         self.row_colors = ['e5e3e3', 'FFFFFF']

         row(0).style(:align => :center, :font_style => :bold, :height => 35, :valign => :center)
         column(0..7).style(:align => :center)
         column(1..7).style(:width => 60)
      end
   end
   
   
   def line_item_rows
      [["STT", "Tên Lớp", "Tổng Số", "Nghỉ Luôn", "Chuyển Xứ", "Đang Học", "Lên Lớp",  "Học Lại"]] + 
      @cells.map do |cell|
         [
            @cells.index(cell),
            cell.name, 
            cell.attendances.count, 
            cell.attendances.where(result: "Nghỉ Luôn").count,
            cell.attendances.where(result: "Chuyển Xứ").count,
            cell.attendances.where(result: "Đang Học").count, 
            cell.attendances.where(result: "Lên Lớp").count,
            cell.attendances.where(result: "Học Lại").count
         ] 
      end
   end
   
   def footer
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text "Ban Giáo Lý Giáo Xứ  Mẫu Tâm", size: 6, align: :right  
      end
      bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
        text "In ngày: #{Time.zone.now.strftime("%d/%m/%Y")}", size: 6, align: :left  
      end
   end
end