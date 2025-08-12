class Api::PeopleController < ApplicationController
  skip_before_action :auth # TODO: authorize
  before_action :set_person, except: %i[index]

  def index
    @people = scope.result.sort_by(&:sort_param)

    render json: @people
  end

  def show
    render json: @person
  end

private

  def scope
    Person.ransack(params[:filters])
  end

  def set_person
    @person = Person.find(params[:id] || params[:person_id])
  end
end
