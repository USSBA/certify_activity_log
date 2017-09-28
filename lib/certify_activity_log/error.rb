# error helpers for activities
module CertifyActivityLog
  # Custom error class for rescuing from all activity log API errors
  class Error < StandardError; end

  # Raised when activity log API returns the HTTP status code 400
  class BadRequest < Error; end

  # Raised when activity log API returns the HTTP status code 404
  class NotFound < Error; end

  # Raised when activity log API returns the HTTP status code 500
  class InternalServerError < Error; end

  # Raised when activity log API returns the HTTP status code 503
  class ServiceUnavailable < Error; end

  def self.service_unavailable(error)
    {body: "Service Unavailable: There was a problem connecting to the activity log API. Type: #{error}", status: 503}
  end

  # Raised when activity log API returns the HTTP status code 400
  def self.bad_request
    {body: "Bad Request: No parameters submitted", status: 400}
  end

  def self.unprocessable
    {body: "Unprocessable Entity: Invalid parameters submitted", status: 422}
  end
end
