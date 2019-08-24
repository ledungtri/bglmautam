class Student < ActiveRecord::Base
    has_many :attendances
    has_many :cells, through: :attendances
    
    validates_presence_of :full_name, :gender, :date_birth
    validates :gender, inclusion: { in: %w(Nam Nữ), message: "have to be either Nam or Nữ" }
    
    validates_presence_of :date_baptism, if: :place_baptism?
    validates_presence_of :date_communion, if: :place_communion?
    validates_presence_of :date_confirmation, if: :place_confirmation?
    validates_presence_of :date_declaration, if: :place_declaration?
    
    validates_presence_of :street_name, if: :street_number? or :ward? or :district?
    
    validates :phone, format: { with: /\A\d+\z/, message: "only allows numbers" }, allow_blank: true
    validates :father_phone, format: { with: /\A\d+\z/, message: "only allows numbers" }, allow_blank: true
    validates :mother_phone, format: { with: /\A\d+\z/, message: "only allows numbers" }, allow_blank: true
    
    
    def name
        if christian_name?
            christian_name + " " + full_name
        else
            full_name
        end
    end
    
    def address
       self.street_number + " " + self.street_name + ", " + self.ward + ", " + self.district if self.street_name?
    end
    
    def result(cell)
       self.attendances.where(student_id: self.id, cell_id: cell.id).take.result 
    end
    
    def father_name
        if father_christian_name? && father_full_name?
            father_christian_name + " " + father_full_name
        elsif father_full_name?
            father_full_name
        end
    end
    
    def mother_name
        if mother_christian_name? && mother_full_name?
            mother_christian_name + " " + mother_full_name
        else
            mother_full_name
        end
    end
    
    def sort_param
        self.name.split(/\s+/).reverse!.join(" ").
        gsub(/[áàảãạăắặằẳẵâấầẩẫậ]/, 'a').
        gsub(/[íìỉĩị]/, 'i').
        gsub(/[úùủũụưứừửữự]/, 'u').
        gsub(/[éèẻẽẹêếềểễệ]/, 'e').
        gsub(/[óòỏõọôốồổỗộơớờởỡợ]/, 'o').
        gsub(/[đ]/, 'd').
        gsub(/[ýỳỷỹỵ]/, 'y').
        gsub(/[ÁÀẢÃẠĂẮẶẰẲẴÂẤẦẨẪẬ]/, 'A').
        gsub(/[ÍÌỈĨỊ]/, 'I').
        gsub(/[ÚÙỦŨỤƯỨỪỬỮỰ]/, 'U').
        gsub(/[ÉÈẺẼẸÊẾỀỂỄỆ]/, 'E').
        gsub(/[ÓÒỎÕỌÔỐỒỔỖỘƠỚỜỞỠỢ]/, 'O').
        gsub(/[Đ]/, 'D').
        gsub(/[ÝỲỶỸỴ]/, 'Y')
    end
end