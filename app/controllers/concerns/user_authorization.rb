module UserAuthorization
  include CustomError
  def raise_user_not_found(user)
    logger.error("User not found: #{user}")
    raise CustomError::AuthenticationError.new('Invalid email, does not exist', BAD_REQUEST)
  end
end
