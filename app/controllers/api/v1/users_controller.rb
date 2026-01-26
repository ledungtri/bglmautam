# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      before_action :require_admin!
      before_action :set_user, only: [:show, :update, :destroy]

      # GET /api/v1/users
      def index
        @users = User.page(params[:page]).per(params[:per_page] || 50)
        render json: @users.map { |u| user_json(u) }, meta: pagination_meta(@users)
      end

      # GET /api/v1/users/:id
      def show
        render json: user_json(@user)
      end

      # POST /api/v1/users
      def create
        @user = User.new(user_params)

        if @user.save
          render json: user_json(@user), status: :created
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /api/v1/users/:id
      def update
        if @user.update(user_params)
          render json: user_json(@user)
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id
      def destroy
        @user.destroy
        head :no_content
      end

      private

      def require_admin!
        render json: { error: 'Admin access required' }, status: :forbidden unless current_user.admin?
      end

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:username, :password, :password_confirmation, :teacher_id, :admin)
      end

      def user_json(user)
        {
          id: user.id,
          username: user.username,
          admin: user.admin,
          teacher_id: user.teacher_id,
          person_id: user.person_id,
          person_name: user.person&.full_name,
          created_at: user.created_at,
          updated_at: user.updated_at
        }
      end
    end
  end
end
