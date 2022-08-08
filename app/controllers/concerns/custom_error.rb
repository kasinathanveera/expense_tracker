# frozen_string_literal: true

module CustomError
  BAD_REQUEST                  = 400
  VALIDATION_ERROR             = 400
  UNAUTHORIZED                 = 401
  FORBIDDEN                    = 403
  NOT_FOUND                    = 404
  INTERNAL_SERVER_ERROR        = 500

  class ResponseError < StandardError

    attr_reader :status_code

    def initialize(message, status_code)
      @status_code = status_code
      super(message)
    end
  end

  class AuthenticationError < ResponseError; end
  class ValidationError < ResponseError; end
end
