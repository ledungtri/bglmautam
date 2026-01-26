# frozen_string_literal: true

module Api
  module V1
    class AuthController < ActionController::API
      include ActionController::Cookies

      # Skip authentication for login endpoint
      before_action :authenticate_user!, only: [:me, :logout]

      # POST /api/v1/auth/login
      def login
        user = User.find_by(username: params[:username])

        if user&.authenticate(params[:password])
          tokens = JwtService.generate_tokens(user)
          set_auth_cookies(tokens)
          render json: { user: user_json(user) }, status: :ok
        else
          render json: { error: 'Invalid username or password' }, status: :unauthorized
        end
      end

      # POST /api/v1/auth/logout
      def logout
        clear_auth_cookies
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      # POST /api/v1/auth/refresh
      def refresh
        refresh_token = cookies.signed[:refresh_token]
        return render json: { error: 'No refresh token' }, status: :unauthorized unless refresh_token

        new_access_token = JwtService.refresh_access_token(refresh_token)
        cookies.signed[:access_token] = cookie_options(new_access_token, JwtService::ACCESS_TOKEN_EXPIRY)
        render json: { message: 'Token refreshed' }, status: :ok
      rescue JwtService::TokenExpiredError, JwtService::InvalidTokenError => e
        clear_auth_cookies
        render json: { error: e.message }, status: :unauthorized
      end

      # GET /api/v1/auth/me
      def me
        render json: { user: user_json(current_user) }, status: :ok
      end

      private

      def current_user
        @current_user
      end

      def authenticate_user!
        token = cookies.signed[:access_token]
        return render json: { error: 'Unauthorized' }, status: :unauthorized unless token

        payload = JwtService.decode(token)
        @current_user = User.find(payload[:user_id])
      rescue JwtService::TokenExpiredError, JwtService::InvalidTokenError, ActiveRecord::RecordNotFound
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def set_auth_cookies(tokens)
        cookies.signed[:access_token] = cookie_options(tokens[:access_token], JwtService::ACCESS_TOKEN_EXPIRY)
        cookies.signed[:refresh_token] = cookie_options(tokens[:refresh_token], JwtService::REFRESH_TOKEN_EXPIRY)
      end

      def clear_auth_cookies
        cookies.delete(:access_token)
        cookies.delete(:refresh_token)
      end

      def cookie_options(value, expiry)
        {
          value: value,
          expires: expiry.from_now,
          httponly: true,
          secure: Rails.env.production?,
          same_site: Rails.env.production? ? :strict : :lax
        }
      end

      def user_json(user)
        {
          id: user.id,
          username: user.username,
          person_id: user.person_id,
          person_name: user.person&.name,
          admin: user.admin,
          teacher_id: user.teacher_id
        }
      end
    end
  end
end
