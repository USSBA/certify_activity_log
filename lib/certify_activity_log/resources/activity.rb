module CertifyActivityLog
  # activity class that handles getting and creating new activity log entries
  class Activity < Resource
    SOFT_VALIDATION = false
    STRICT_VALIDATION = true

    # get list of activities for a person
    # rubocop:disable Metrics/AbcSize
    def self.where(params = nil)
      return CertifyActivityLog.bad_request if empty_params(params)
      safe_params = activity_safe_params params
      return CertifyActivityLog.unprocessable if safe_params.empty?
      response = connection.request(method: :get,
                                    path: build_where_activities_path(safe_params))
      return_response(json(response.data[:body]), response.data[:status])
    rescue Excon::Error => error
      handle_excon_error(error)
    end
    singleton_class.send(:alias_method, :find, :where)

    def self.create(params = nil)
      create_soft(params)
    end

    # gem method for accessing the API export method and returning a csv of the data
    def self.export(params = nil)
      return CertifyActivityLog.bad_request if empty_params(params) || application_param(params).nil?
      response = connection.request(method: :get,
                                    path: build_export_activities_path(params))
      return_response(response.data[:body], response.data[:status])
    rescue Excon::Error => error
      handle_excon_error(error)
    end

    # create a set of activities with soft validation
    def self.create_soft(params = nil)
      return CertifyActivityLog.bad_request if empty_params(params)
      safe_params = activity_create_safe_param(SOFT_VALIDATION, params)
      activity_create_request safe_params
    end

    # create a set of activities with strict validation
    def self.create_strict(params = nil)
      return CertifyActivityLog.bad_request if empty_params(params)
      safe_params = activity_create_safe_param(STRICT_VALIDATION, params)
      activity_create_request safe_params
    end

    private_class_method

    def self.version_specific_keys
      case activity_api_version
      when 1
        %w[sender_id recipient_id application_id]
      when 2
        %w[sender_uuid recipient_uuid application_id]
      when 3
        %w[sender_uuid recipient_uuid application_uuid]
      end
    end

    # returns the body as a parsed JSON hash, or as a simple hash if nil
    def self.parse_body(body)
      body.empty? ? { message: 'No Content' } : json(body)
    end

    # helper for white listing parameters
    def self.activity_safe_params(p)
      permitted_keys = %w[id activity_type event_type subtype options body page per_page]
      permitted_keys.push(*version_specific_keys)
      symbolize_params(p.select { |key, _| permitted_keys.include? key.to_s })
    end

    def self.application_param(p)
      case activity_api_version
      when 1, 2
        p[:application_id]
      when 3
        p[:application_uuid]
      end
    end

    def self.activity_create_safe_param(strict, p)
      safe_params = {strict: strict}
      safe_params[:activities] = []
      [p].flatten(1).each do |activity_params|
        safe_params[:activities].push(activity_safe_params(activity_params)) unless activity_safe_params(activity_params).empty?
      end
      safe_params
    end

    def self.activity_create_request(safe_params)
      return CertifyActivityLog.unprocessable if safe_params[:activities].empty?
      response = connection.request(method: :post,
                                    path: build_create_activities_path,
                                    body: safe_params.to_json,
                                    headers:  { "Content-Type" => "application/json" })
      return_response(parse_body(response.data[:body]), response.data[:status])
    rescue Excon::Error => error
      handle_excon_error(error)
    end

    def self.build_where_activities_path(params)
      "#{path_prefix}/#{activities_path}?#{URI.encode_www_form(params)}"
    end

    def self.build_create_activities_path
      "#{path_prefix}/#{activities_path}"
    end

    def self.build_export_activities_path(params)
      "#{path_prefix}/#{activities_export_path}?column_separator=#{column_separator}&#{URI.encode_www_form(params)}"
    end
  end
end
