class CommentsController < ApplicationController
  before_action :require_user_logged_in!

  def add_expense_comment
    @expense = Expense.find(params[:expense_id])
    @comment = @expense.add_comment(current_user.id, comment_args)
    notify_comment(@expense.user)
  end

  def index_expense_comments
    @comments = Expense.find(params[:expense_id]).comments
  end

  def add_report_comment
    @report = Report.find(params[:report_id])
    @comment = @report.add_comment(current_user.id, comment_args)
    notify_comment(@report.user)
  end

  def index_report_comments
    @comments = Report.find(params[:report_id]).comments
  end

  private

  def comment_args
    params.permit(:parent_id, :comment)
  end

  def notify_comment(expense_user)
    UserMailer.with(current_user: current_user, user: expense_user,
                    comment: @comment).notify_comment.deliver_now
  end
end
