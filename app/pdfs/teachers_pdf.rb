class TeachersPdf < Prawn::Document
   def initialize(teachers, year)
      super(:page_size => "A4", :page_layout => :landscape, :margin => 20) 
      @teachers = teachers
      @year = year
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
       text "Danh Sách Giáo Lý Viên Năm Học #{@year.to_s + " - " + (@year+1).to_s}", :size => 15, :align => :center, :style => :bold
       text "Số Lượng: #{@teachers.count}",:size => 10, :align => :center
       
   end
   
   def line_items
       bounding_box([0, cursor], :width => bounds.width, :height => bounds.height-50) do
        table line_item_rows do
            self.header = true
            self.position = :center
            self.row_colors = ['e5e3e3', 'FFFFFF']
            
            row(0).style(:align => :center, :font_style => :bold, :height => 35, :valign => :center)
            
            column(1).style(:align => :center, :width => 60)
            column(2).style(:align => :center, :width => 90)
            column(5).style(:align => :center, :width => 60)
            column(6).style(:align => :center, :width => 60)
        end
       end
   end
   
   def line_item_rows
        [["Họ và Tên", "Ngày Sinh", "Nghề Nghiệp", "Địa Chỉ", "Điện Thoại", "Lớp", "Phụ Trách"]] +
        @teachers.map do |teacher|
           [teacher.name, teacher.date_birth.strftime("%d/%m/%Y"), teacher.occupation, teacher.address, teacher.phone,
           teacher.cells.where(year: @year).first.name,
           teacher.cells.where(year: @year).first.instructions.where(teacher_id: teacher.id).first.position] 
        end
   end
   
   def footer
        page_count.times do |i|
            go_to_page(i+1)
            bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
                text "Ban Giáo Lý Giáo Xứ  Mẫu Tâm", size: 6, align: :right  
            end
            bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
                text "In ngày: #{Time.zone.now.strftime("%d/%m/%Y")}", size: 6, align: :left  
            end   
            bounding_box [bounds.left, bounds.bottom + 10], width: bounds.width do
                text "Trang #{i+1}/#{page_count}", size: 6, align: :center  
            end   
        end
   end
end