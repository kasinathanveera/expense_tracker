class UserRole < ApplicationRecord
  belongs_to :user

  enum role: {
    basic: 0,
    admin: 1
  }
  
end
