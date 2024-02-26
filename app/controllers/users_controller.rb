class UsersController < ApplicationController
  before_action :set_user, only: %i[update destroy admin_or_self?]
  before_action :auth
  before_action :admin?, except: %i[update]
  before_action :admin_or_self?, only: %i[update]

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        flash[:success] = 'User was successfully created.'
        format.html { redirect_to @user }
      else
        format.html { render @user.teacher }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        flash[:success] = 'User was successfully updated.'
      end
      format.html { redirect_to @user.teacher }
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      flash[:success] = 'User was successfully destroyed.'
      format.html { redirect_to @user.teacher }
    end
  end

  private

  def admin_or_self?
    return if @current_user&.admin_or_self?(@user)

    flash[:warning] = 'Action not allowed. You are not an admin.'
    redirect_back(fallback_location: root_path)
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :teacher_id)
  end
end
