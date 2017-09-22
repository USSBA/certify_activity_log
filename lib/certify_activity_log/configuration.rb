module CertifyActivityLog
  # configuration module
  class Configuration
    attr_accessor :api_url, :activity_api_version, :path_prefix, :activities_path

    # main api endpoint
    def initialize
      @api_url = nil
      @activity_api_version = 1
      @path_prefix = "/activity_log"
      @activities_path = "activities"
    end
  end
end