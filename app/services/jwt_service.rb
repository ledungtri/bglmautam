# frozen_string_literal: true

class JwtService
  SECRET_KEY = Rails.application.secret_key_base
  ALGORITHM = 'HS256'

  # Token expiration times
  ACCESS_TOKEN_EXPIRY = 15.minutes
  REFRESH_TOKEN_EXPIRY = 7.days

  class << self
    # Encode a payload into a JWT token
    def encode(payload, expiration: ACCESS_TOKEN_EXPIRY)
      payload[:exp] = expiration.from_now.to_i
      payload[:iat] = Time.current.to_i
      JWT.encode(payload, SECRET_KEY, ALGORITHM)
    end

    # Decode a JWT token
    def decode(token)
      decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::ExpiredSignature
      raise TokenExpiredError
    rescue JWT::DecodeError => e
      raise InvalidTokenError, e.message
    end

    # Generate access and refresh tokens for a user
    def generate_tokens(user)
      access_token = encode({ user_id: user.id, type: 'access' }, expiration: ACCESS_TOKEN_EXPIRY)
      refresh_token = encode({ user_id: user.id, type: 'refresh' }, expiration: REFRESH_TOKEN_EXPIRY)
      { access_token: access_token, refresh_token: refresh_token }
    end

    # Verify refresh token and generate new access token
    def refresh_access_token(refresh_token)
      payload = decode(refresh_token)
      raise InvalidTokenError, 'Invalid token type' unless payload[:type] == 'refresh'

      user = User.find(payload[:user_id])
      encode({ user_id: user.id, type: 'access' }, expiration: ACCESS_TOKEN_EXPIRY)
    end
  end

  # Custom error classes
  class TokenExpiredError < StandardError
    def message
      'Token has expired'
    end
  end

  class InvalidTokenError < StandardError; end
end
