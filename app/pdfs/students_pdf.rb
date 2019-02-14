class StudentsPdf < Prawn::Document
   def initialize(arrays, cell)
      super(:page_size => "A4", :page_layout => :landscape, :margin => 20) 
      @arrays = arrays
      @cell = cell
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
       total = 0
       @arrays.each do |a|
          total += a.count 
       end
       text "Danh Sách Lớp #{@cell.name}\nNăm Học #{@cell.long_year}", :size => 15, :align => :center, :style => :bold
       text "Số Lượng: #{total}",:size => 10, :align => :center
   end
   
   def line_items
       bounding_box([0, cursor], :width => bounds.width, :height => bounds.height-80) do
           @arrays.map do |students| 
               if !students.empty?
                   @students = students
                   table line_item_rows do
                        self.header = true
                        self.position = :center
                        self.row_colors = ['e5e3e3', 'FFFFFF']
                        
                        row(0).style(:align => :center, :font_style => :bold, :height => 35, :valign => :center)
                        
                        column(0).style(:width => 250)
                        column(1).style(:width => 60, :align => :center)
                        column(2).style(:width => 250)
                        column(3).style(:width => 60, :align => :center)
                        column(4).style(:width => 60, :align => :center)
                        column(5).style(:width => 60, :align => :center)
                        column(6).style(:width => 60, :align => :center)
                   end
                   bounding_box([bounds.width-60, cursor], :width => 60) do
                       text "#{students.first.result(@cell)}: #{students.count}", :align => :center
                       move_down 10
                   end
               end
           end
       end
   end
   
   def line_item_rows
        [["Họ và Tên", "Ngày Sinh", "Địa Chỉ", "ĐT Cha", "ĐT Mẹ", "Lớp", "Kết Quả"]] +
        @students.map do |student|
            [student.name, student.date_birth.strftime("%d/%m/%Y"), student.address, student.father_phone, student.mother_phone, @cell.name, student.result(@cell)] 
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