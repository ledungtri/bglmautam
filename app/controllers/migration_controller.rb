class MigrationController < ApplicationController
    before_action :auth, :isAdmin

    def mass_process_end_of_year_result
        attendances = Attendance.where(year: @current_year, result: "Đang Học")
        attendances.each do |attendance| 
        attendance.result = "Lên Lớp"
        attendance.save
        end
        redirect_to root_url
    end
    
end