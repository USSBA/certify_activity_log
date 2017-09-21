require 'json'
require 'excon'

module CertifyActivityLog
  # Controls the API connection
  class ApiConnection
    def initialize(url)
      @conn = Excon.new(url)
    end

    def request(options)
      add_version_to_header options
      @conn.request(options)
    end

    def add_version_to_header(options)
      version = CertifyActivityLog.configuration.notify_api_version
      if options[:headers]
        options[:headers].merge!('Accept' => "application/sba.activity-api.v#{version}")
      else
        options.merge!(headers: { 'Accept' => "application/sba.activity-api.v#{version}" })
      end
    end
  end

  # base resource class
  # rubocop:disable Style/ClassVars
  class Resource
    @@connection = nil

    # excon connection
    def self.connection
      @@connection ||= ApiConnection.new api_url
    end

    def self.clear_connection
      @@connection = nil
    end

    def self.api_url
      CertifyActivityLog.configuration.api_url
    end

    def self.path_prefix
      CertifyActivityLog.configuration.path_prefix
    end

    def self.activities_path
      CertifyActivityLog.configuration.activities_path
    end

    def self.activity_preferences_path
      CertifyActivityLog.configuration.activity_preferences_path
    end

    def self.activity_log_path
      CertifyActivityLog.configuration.activity_log_path
    end

    # json parse helper
    def self.json(response)
      JSON.parse(response)
    end

    # empty params
    def self.empty_params(params)
      params.nil? || params.empty?
    end

    def self.return_response(body, status)
      { body: body, status: status }
    end

    def self.symbolize_params(p)
      # rebuild params as symbols, dropping ones as strings
      symbolized_params = {}
      p.each do |key, value|
        if key.is_a? String
          symbolized_params[key.to_sym] = value
        else
          symbolized_params[key] = value
        end
      end
      symbolized_params
    end
  end
end
