class UserMailer < ApplicationMailer
  def expense_update
    @user = params[:user]
    @expense = params[:expense]
    mail(to: @user.email, subject: 'Expense update')
  end

  def report_update
    @user = params[:user]
    @report = params[:report]
    @total_amount = @report.total_amount
    @total_approved_amount = @report.total_approved_amount
    mail(to: @user.email, subject: 'Report update')
  end

  def notify_comment
    @user = params[:user]
    @comment = params[:comment]
    @commented_by = params[:current_user].name
    mail(to: @user.email, subject: 'Comment update')
  end

end
