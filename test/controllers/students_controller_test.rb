require 'test_helper'

class StudentsControllerTest < ActionController::TestCase
  setup do
    @student = students(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:students)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create student" do
    assert_difference('Student.count') do
      post :create, student: { area: @student.area, christian_name: @student.christian_name, date_baptism: @student.date_baptism, date_birth: @student.date_birth, date_comfirmation: @student.date_comfirmation, date_communion: @student.date_communion, date_declaration: @student.date_declaration, district: @student.district, father_christian_name: @student.father_christian_name, father_full_name: @student.father_full_name, father_phone: @student.father_phone, full_name: @student.full_name, gender: @student.gender, home_phone: @student.home_phone, mother_christian_name: @student.mother_christian_name, mother_full_name: @student.mother_full_name, mother_phone: @student.mother_phone, phone: @student.phone, place_baptism: @student.place_baptism, place_birth: @student.place_birth, place_communion: @student.place_communion, place_confirmation: @student.place_confirmation, place_declaration: @student.place_declaration, street_name: @student.street_name, street_number: @student.street_number, ward: @student.ward }
    end

    assert_redirected_to student_path(assigns(:student))
  end

  test "should show student" do
    get :show, id: @student
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @student
    assert_response :success
  end

  test "should update student" do
    patch :update, id: @student, student: { area: @student.area, christian_name: @student.christian_name, date_baptism: @student.date_baptism, date_birth: @student.date_birth, date_comfirmation: @student.date_comfirmation, date_communion: @student.date_communion, date_declaration: @student.date_declaration, district: @student.district, father_christian_name: @student.father_christian_name, father_full_name: @student.father_full_name, father_phone: @student.father_phone, full_name: @student.full_name, gender: @student.gender, home_phone: @student.home_phone, mother_christian_name: @student.mother_christian_name, mother_full_name: @student.mother_full_name, mother_phone: @student.mother_phone, phone: @student.phone, place_baptism: @student.place_baptism, place_birth: @student.place_birth, place_communion: @student.place_communion, place_confirmation: @student.place_confirmation, place_declaration: @student.place_declaration, street_name: @student.street_name, street_number: @student.street_number, ward: @student.ward }
    assert_redirected_to student_path(assigns(:student))
  end

  test "should destroy student" do
    assert_difference('Student.count', -1) do
      delete :destroy, id: @student
    end

    assert_redirected_to students_path
  end
end
