require "certify_activity_log/configuration"
require "certify_activity_log/error"
require "certify_activity_log/resource"
require "certify_activity_log/version"
require "certify_activity_log/resources/activity"

# the base CertifyActivityLog module that wraps all activity log calls
module CertifyActivityLog
  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
