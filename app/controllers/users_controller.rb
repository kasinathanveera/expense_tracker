class UsersController < ApplicationController
  require 'logger'
  include UserAuthorization

  skip_before_action :current_user

  def create
    @user = User.create(onboard_args)
    @user.validate
    @user.add_roles(params[:user][:roles])
    render status: :created
  end

  def signup
    email = params[:user][:email]
    @user = User.find_by(email:)
    raise_user_not_found(email) if @user.nil?
    @user.update(password: params[:user][:password])
    session[:user_id] = @user.id
    render status: :created
  end

  private

  def onboard_args
    user_details = params.require(:user).permit(:name, :email, :department)
    user_details['password'] = 'SUDO'
    user_details
  end
end
