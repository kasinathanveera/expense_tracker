class ApplicationController < ActionController::API
  include Pundit::Authorization
  include CustomError

  before_action :current_user

  rescue_from StandardError, with: :error_response_handler
  
  def current_user
    @current_user = User.find(session[:user_id]) if session[:user_id]
  end

  def require_user_logged_in!
    if @current_user.nil?
      logger.error('User not logged in')
      raise CustomError::AuthenticationError.new('Please login and then proceed further', UNAUTHORIZED)
    end
  end

  def error_response_handler(exception)
    status_code = INTERNAL_SERVER_ERROR
    message = exception.message
    if exception.is_a?(ResponseError)
      status_code = exception.status_code
    elsif exception.instance_of?(ActiveRecord::RecordNotFound)
      status_code = :not_found
    else
      message = 'Something went wrong'
    end
    render json: { error_message: message }, status: status_code
  end
end
