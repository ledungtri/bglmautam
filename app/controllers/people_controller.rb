# == Schema Information
#
# Table name: people
#
#  id             :integer          not null, primary key
#  birth_date     :date             not null
#  birth_place    :string
#  christian_name :string
#  data           :jsonb
#  deleted_at     :datetime
#  gender         :string           not null
#  name           :string           not null
#  nickname       :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class PeopleController < ApplicationController
  before_action :set_person, except: %i[index create]

  def index

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
      :christian_name,
      :name,
      :nickname,
      :birth_date,
      :birth_place,
      :gender
    )
  end
end
