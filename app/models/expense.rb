class Expense < ApplicationRecord
  include InvoiceValidator

  belongs_to :user

  before_create :set_expense_status

  has_one_attached :document

  has_many :comments, as: :commentable

  validates :invoice_number, presence: true, uniqueness: true
  validates :amount, presence: true
  validates :description, presence: true

  enum status: {
    drafted: 0,
    submitted: 1,
    verified: 2,
    approved: 3,
    rejected: 4
  }

  def set_expense_status
    self.status = :drafted
  end

  def validate
    unless errors.empty?
      logger.error("Errors found with expense: #{id}, exception #{errors.full_messages}")
      raise CustomError::ValidationError.new(errors.full_messages.to_s, CustomError::VALIDATION_ERROR)
    end
  end

  def validate_invoice
    json_reponse = invoice_validator_response(invoice_number)
    if json_reponse['status']
      self.status = :verified
      store_invoice_validations(json_reponse)
    else
      self.status = :rejected
    end
  end

  def add_comment(user_id, args)
    comments.create(parent_id: args[:parent_id], comment: args[:comment], user_id: user_id)
  end

end
