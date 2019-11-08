class Cell < ActiveRecord::Base
    has_many :attendances
    has_many :students, through: :attendances
    
    has_many :instructions
    has_many :teachers, through: :instructions
    
    validates_presence_of :year, :grade
    validates :group, format: { with: /\A\d?[A-Z]?\z/, message: "invalid input" }, allow_blank: true
    
    def long_year
        if self.year != nil
            self.year.to_s + " - " + (self.year+1).to_s
        end
    end
    
    def name 
        if self.group?
           self.grade + " " + self.group 
        else
           self.grade 
        end
    end
    
    def sort_param 
       case
       when self.grade == "Trưởng Ban"
            "0"
       when self.grade == "Kỹ Thuật"
            "1"
       when self.grade == "Khai Tâm"
            "2" + self.group
       when self.grade == "Rước Lễ"
            "3" + self.group
       when self.grade == "Thêm Sức"
            "4" + self.group
       when self.grade == "Bao Đồng"
            "5" + self.group
       else
            "6"
       end
    end
end
