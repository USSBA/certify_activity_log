module CertifyActivityLog
  # configuration module
  class Configuration
    attr_accessor :excon_timeout, :api_url, :activity_api_version, :path_prefix, :activities_path, :activities_export_path, :logger, :log_level, :column_separator

    # main api endpoint
    def initialize
      @excon_timeout = 20
      @api_url = "http://localhost:3005"
      @activity_api_version = 1
      @path_prefix = "/activity_log"
      @activities_path = "activities"
      @activities_export_path = "export"
      @log_level = "debug"
      @logger = nil
      @column_separator = "|"
    end
  end
end
