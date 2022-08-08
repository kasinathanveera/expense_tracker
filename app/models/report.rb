class Report < ApplicationRecord
  include InvoiceValidator

  belongs_to :user

  has_many :expenses

  has_many :comments, as: :commentable

  attr_reader :already_processed_expenses

  before_create :filter_out_processed

  before_update :submit_dependent_expense

  enum status: {
    drafted: 0,
    verified: 1,
    submitted: 2,
    processed: 3
  }

  def total_amount
    expenses.inject(0) do |amount, e|
      amount + e.amount
    end
  end

  def total_approved_amount
    expenses.inject(0) do |amount, e|
      amount + e.approved_amount
    end
  end

  def submit_dependent_expense
    if status == 'submitted'
      expenses.select { |e| e.drafted? }.each do |expense|
        json = invoice_validator_response(expense.invoice_number)
        response = json['status'] ? 'verified' : 'rejected'
        expense.update(status: response) if expense.drafted?
      end
    end
  end

  def update_dependent_expense(update_expenses)
    update_expenses.each do |e|
      expense = expenses.find(e[:id])
      expense.update(status: e[:status], approved_amount: e[:approved_amount]) if expense.verified?
    end
  end

  def add_comment(user_id, args)
    comments.create(parent_id: args[:parent_id], comment: args[:comment], user_id: user_id)
  end

  private

  def filter_out_processed
    @already_processed_expenses = []
    expenses.each do |expense|
      log_mapped_expense(expense) unless expense.report_id.nil? && expense.drafted?
    end
    self.expenses = expenses.reject { |expense| @already_processed_expenses.include?(expense.id) }
    raise_validation_error if expenses.size.zero?
  end

  def raise_validation_error
    raise CustomError::ValidationError.new('Report cannot be generated,expenses are unprocessable',
                                           CustomError::VALIDATION_ERROR)
  end

  def log_mapped_expense(expense)
    logger.error("expense #{expense.id} is already mapped or processed report #{expense.report_id}")
    @already_processed_expenses.push(expense.id)
  end
end
