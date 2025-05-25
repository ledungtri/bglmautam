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
    respond_to do |format|
      if @person.update(person_params)
        flash[:success] = 'Person was successfully updated.'
      end
      format.html { redirect_to @person }
    end
  end

  private

  def set_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit(
      :christian_name,
      :name,
      :birth_date,
      :birth_place,
      :gender
    )
  end
end
