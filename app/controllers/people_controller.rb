# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  area               :string
#  avatar_url         :string
#  birth_date         :date             not null
#  birth_place        :string
#  christian_name     :string
#  city               :string
#  data               :jsonb
#  date_baptism       :date
#  date_communion     :date
#  date_confirmation  :date
#  date_declaration   :date
#  deleted_at         :datetime
#  district           :string
#  email              :string
#  gender             :string           not null
#  name               :string           not null
#  nickname           :string
#  phone              :string
#  place_baptism      :string
#  place_communion    :string
#  place_confirmation :string
#  place_declaration  :string
#  province           :string
#  province_code      :integer
#  street_address     :string
#  street_name        :string
#  street_number      :string
#  subregion          :string
#  ward               :string
#  ward_code          :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  organization_id    :bigint           not null
#
# Indexes
#
#  index_people_on_organization_id  (organization_id)
#
# Foreign Keys
#
#  fk_rails_...  (organization_id => organizations.id)
#
class PeopleController < ApplicationController
  before_action :set_person, except: %i[index create]

  def index
     authorize Person

    @teaching_assignments = TeachingAssignment.joins(:classroom).where('classrooms.year = ?', @current_year).sort_by(&:sort_param)
    respond_to do |format|
      format.html
    end
  end

  def show

  end

  def create

  end

  def update
    flash[:success] = 'Person was successfully updated.' if @person.update(person_params)
    redirect_back(fallback_location: root_path)
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(
      :christian_name, :name, :nickname, :birth_date, :birth_place, :gender, :avatar_url,
      :phone, :email, :street_number, :street_name, :ward, :district, :city, :area
    )
  end
end
