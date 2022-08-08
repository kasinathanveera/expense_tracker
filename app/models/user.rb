class User < ApplicationRecord
  include CustomError

  has_secure_password

  has_many :user_roles
  has_many :expenses
  has_many :reports

  validates :email, presence: true, uniqueness: true,
                    format: { with: /\A[^@\s]+@[^@\s]+\z/, message: 'Invalid email' }, on: :create

  before_create :set_active_status

  enum status: {
    inactive: 0,
    active: 1
  }

  def validate
    unless errors.empty?
      logger.error("unable to onboard user, exception #{errors.full_messages}")
      raise CustomError::ValidationError.new("unable to onboard user, #{errors.full_messages}", VALIDATION_ERROR)
    end
  end

  def add_roles(roles)
    roles.each do |role|
      user_roles.create(role:)
    end
  end

  def set_active_status
    self.status = :active
  end

  def admin?
    user_roles.each do |role|
      return true if role.admin?
    end
    false
  end
end
