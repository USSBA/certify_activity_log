require 'json'
require 'excon'

module CertifyActivityLog
  # Controls the API connection
  class ApiConnection
    attr_accessor :conn
    def initialize(url, timeout)
      @conn = Excon.new(url,
                        connect_timeout: timeout,
                        read_timeout: timeout,
                        write_timeout: timeout)
    end

    def request(options)
      add_version_to_header options
      @conn.request(options)
    end

    def add_version_to_header(options)
      version = CertifyActivityLog.configuration.activity_api_version
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
      @@connection ||= ApiConnection.new api_url, excon_timeout
    end

    def self.clear_connection
      @@connection = nil
    end

    def self.excon_timeout
      CertifyActivityLog.configuration.excon_timeout
    end

    def self.api_url
      CertifyActivityLog.configuration.api_url
    end

    def self.activity_api_version
      CertifyActivityLog.configuration.activity_api_version
    end

    def self.path_prefix
      CertifyActivityLog.configuration.path_prefix
    end

    def self.activities_path
      CertifyActivityLog.configuration.activities_path
    end

    def self.activities_export_path
      CertifyActivityLog.configuration.activities_export_path
    end

    def self.activity_preferences_path
      CertifyActivityLog.configuration.activity_preferences_path
    end

    def self.activity_log_path
      CertifyActivityLog.configuration.activity_log_path
    end

    def self.logger
      CertifyActivityLog.configuration.logger ||= (DefaultLogger.new log_level).logger
    end

    def self.log_level
      CertifyActivityLog.configuration.log_level
    end

    def self.column_separator
      CertifyActivityLog.configuration.column_separator
    end

    def self.handle_excon_error(error)
      logger.error [error.message, error.backtrace.join("\n")].join("\n")
      CertifyActivityLog.service_unavailable error.message
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
