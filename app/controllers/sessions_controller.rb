class SessionsController < ApplicationController
  include UserAuthorization

  skip_before_action :current_user

  def create
    email = params[:email]
    @user = User.find_by(email:)
    raise_user_not_found(email) if @user.nil?
    raise_password_mismatch unless @user.authenticate(params[:password])
    session[:user_id] = @user.id
  end

  def destroy
    session[:user_id] = nil
  end

  private

  def raise_password_mismatch
    logger.error("password mismatch for user: #{@user.email}")
    raise CustomError::AuthenticationError.new('passwoard does not match', BAD_REQUEST)
  end
end
