# frozen_string_literal: true

module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::Cookies
      include Pundit::Authorization

      before_action :authenticate_user!

      # Error handling
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity
      rescue_from Pundit::NotAuthorizedError, with: :forbidden
      rescue_from JwtService::TokenExpiredError, with: :token_expired
      rescue_from JwtService::InvalidTokenError, with: :unauthorized

      protected

      def current_user
        @current_user
      end

      def authenticate_user!
        token = cookies.signed[:access_token]
        return unauthorized unless token

        payload = JwtService.decode(token)
        return unauthorized unless payload[:type] == 'access'

        @current_user = User.find(payload[:user_id])
      rescue ActiveRecord::RecordNotFound
        unauthorized
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count,
          per_page: collection.limit_value
        }
      end

      private

      def not_found
        render json: { error: 'Not found' }, status: :not_found
      end

      def unprocessable_entity(exception)
        render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
      end

      def forbidden
        render json: { error: 'Forbidden' }, status: :forbidden
      end

      def unauthorized
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end

      def token_expired
        render json: { error: 'Token expired' }, status: :unauthorized
      end
    end
  end
end
