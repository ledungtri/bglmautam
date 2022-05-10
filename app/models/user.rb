class User < ApplicationRecord
  acts_as_paranoid
  has_secure_password
end
