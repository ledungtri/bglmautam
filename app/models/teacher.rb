class Teacher < ActiveRecord::Base
    # has_secure_password
    has_many :instructions
    has_many :cells, through: :instructions
    
    validates_presence_of :full_name, :date_birth
    validates_presence_of :street_name, if: :street_number? or :ward? or :district?
    validates :phone, format: { with: /\A\d+\z/, message: "only allows numbers" }, allow_blank: true
    # email = right format, allow nil
    
    def name 
       if self.christian_name
          self.christian_name + " " + self.full_name 
       else
           self.full_name
       end
    end
    
    def address
        self.street_number + " " + self.street_name + ", " + self.ward + ", " + self.district if self.street_name?
    end
end
