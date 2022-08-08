class ReportsController < ApplicationController
  include UserAuthorization

  before_action :require_user_logged_in!

  def create
    find_user
    authorize @user
    @report = @user.reports.create(status: 'drafted', expenses:)
  rescue Pundit::NotAuthorizedError => e
    logger.error("User is not active or logged in #{e.inspect}")
    raise CustomError::AuthenticationError.new('Forbidden, user is not active or logged in', FORBIDDEN)
  end

  def show
    find_user
    authorize @user, :access_enabled?
    @report = @user.reports.find(params[:id])
  rescue Pundit::NotAuthorizedError => e
    logger.error("User is not active or logged in #{e.inspect}")
    raise CustomError::AuthenticationError.new('Forbidden, user is not active or logged in', FORBIDDEN)
  end

  def update
    find_user
    authorize @user, :access_enabled?
    report_args = process_report
    unless @report.update(report_args)
      logger.error("Unable to update report #{@expense.id}")
      raise CustomError::ValidationError.new('Unable to update report', BAD_REQUEST)
    end
    notify_report_update if @report.processed?
  end

  private

  def find_user
    @user = User.find(params[:user_id])
    raise_user_not_found(params[:user_id]) if @user.nil?
  end

  def expenses
    @user.expenses.select { |expense| params[:expenses].include?(expense.id) }
  end

  def process_report
    if current_user.admin?
      @report = Report.find(params[:id])
      raise_restricted_action('cannot act upon draft version') if @report.drafted?
      process_depenedent_expenses
      admin_update_args
    else
      @report = @user.reports.find(params[:id])
      authorize_report_status
      user_update_args
    end
  end

  def process_depenedent_expenses
    @report.update_dependent_expense(params[:report][:expenses])
  end

  def authorize_report_status
    authorize @report
  rescue Pundit::NotAuthorizedError => e
    logger.error("Forbidden request, report is not in draft version. #{e.inspect}")
    raise CustomError::ValidationError.new('Forbidden, cannot edit report once it is submitted for approval',
                                           BAD_REQUEST)
  end

  def user_update_args
    raise_restricted_action('actions other than submit are restricted') if params[:status] != 'submitted'
    params.permit(:status)
  end

  def admin_update_args
    raise_restricted_action('actions other than processed are restricted') if params[:report][:status] != 'processed'
    params.require(:report).permit(:status)
  end

  def notify_report_update
    UserMailer.with(user: @user, report: @report).report_update.deliver_now
  end

  def raise_restricted_action(message)
    logger.error(" #{message}: #{params[:id]}")
    raise CustomError::AuthenticationError.new(message, FORBIDDEN)
  end
end
