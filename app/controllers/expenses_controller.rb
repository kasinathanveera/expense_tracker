class ExpensesController < ApplicationController
  include UserAuthorization
  include CustomError

  before_action :require_user_logged_in!

  def create
    find_user
    authorize @user
    add_user_expense
  rescue Pundit::NotAuthorizedError => e
    logger.error("User is not active or logged in #{e.inspect}")
    raise CustomError::AuthenticationError.new('Forbidden, user is not active or logged in', FORBIDDEN)
  end

  def index
    find_user
    authorize @user, :access_enabled?
  rescue Pundit::NotAuthorizedError => e
    logger.error("User is not active or logged in #{e.inspect}")
    raise CustomError::AuthenticationError.new('Forbidden, user is not active or logged in', FORBIDDEN)
  end

  def show
    find_user
    authorize @user, :access_enabled?
    @expense = @user.expenses.find(params[:id])
  rescue Pundit::NotAuthorizedError => e
    logger.error("User is not active or logged in #{e.inspect}")
    raise CustomError::AuthenticationError.new('Forbidden, user is not active or logged in', FORBIDDEN)
  end

  def update
    find_user
    authorize @user, :access_enabled?
    expense_args = process_expense
    unless @expense.update(expense_args)
      logger.error("Unable to update expense #{@expense.id}")
      raise CustomError::ValidationError.new('Unable to update expense', BAD_REQUEST)
    end
    notify_expense_update if @expense.rejected? || @expense.approved?
  end

  private

  def create_expense_args
    params.require(:expense).permit(:description, :amount, :date, :invoice_number, :document)
  end

  def admin_update_args
    status = params[:expense][:status]
    if %w[approved rejected].include?(status)
      params.require(:expense).permit(:approved_amount, :status)
    else
      raise_restricted_action('actions other than approved or rejected are restricted')
    end
  end

  def user_update_args
    p params.require(:expense).permit(:description, :amount, :date, :invoice_number, :document,
                                      { status: ['submitted'] })
  end

  def add_user_expense
    @expense = @user.expenses.create(create_expense_args)
    @expense.validate
  end

  def find_user
    @user = User.find(params[:user_id])
    raise_user_not_found(params[:user_id]) if @user.nil?
  end

  def notify_expense_update
    UserMailer.with(user: @user, expense: @expense).expense_update.deliver_now
  end

  def process_expense
    if current_user.admin?
      @expense = Expense.find(params[:id])
      authorize_submitted_expense
      admin_update_args
    else
      @expense = @user.expenses.find(params[:id])
      authorize_expense_status
      @expense.validate_invoice if params[:expense][:status] == 'submitted'
      user_update_args
    end
  end

  def authorize_expense_status
    authorize @expense
  rescue Pundit::NotAuthorizedError => e
    logger.error("Forbidden request, expense is not in draft version. #{e.inspect}")
    raise CustomError::ValidationError.new('Forbidden, cannot edit expense once it is submitted for approval',
                                           BAD_REQUEST)
  end

  def authorize_submitted_expense
    authorize @expense, :submitted?
  rescue Pundit::NotAuthorizedError => e
    logger.error("Forbidden request, expense is still in  draft version. #{e.inspect}")
    raise CustomError::ValidationError.new('Forbidden, cannot edit expense in the current status.',
                                           BAD_REQUEST)
  end

  def raise_restricted_action(message)
    logger.error(" #{message}: #{params[:id]}")
    raise CustomError::AuthenticationError.new(message, FORBIDDEN)
  end
end
