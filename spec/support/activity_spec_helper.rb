require 'faker'
# Creates mock hashes to be used in simulating activities
module ActivitySpecHelper
  def self.json
    JSON.parse(response.body)
  end

  # helper to replace the rails symbolize_keys method
  def self.symbolize(hash)
    hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
  end

  def self.mock_activities_sym
    [mock_activity_sym, mock_activity_sym, mock_activity_sym]
  end

  # activities can be parameterized with keys as symbols, keys as strings or a mix of symbols and strings
  def self.mock_activity_types
    {
      symbol_keys: mock_activity_sym,
      string_keys: mock_activity_string,
      mixed_keys: mock_activity_mixed
    }
  end

  def self.mock_activity_sym
    { #id:             Faker::Number.number(5), 
      recipient_id:   238,
      application_id: 789,
      activity_type:  "application",
      event_type:     %w[application_state_change].sample,
      subtype:        %w[resubmitted submitted returned].sample,
      options:        { application_id: :application_id , 
                        user_id: 1337,
                        user_name: "Steve Buscemi"}}
  end

  def self.mock_activity_string
    { #"id"             => Faker::Number.number(5),
      "recipient_id"   => 238,
      "application_id" => 789,
      "activity_type"  => "application",
      "event_type"     => %w[application_state_change].sample,
      "subtype"        => %w[resubmitted submitted returned].sample,
      "options"        => { "application_id" => "application_id" , 
                            "user_id" => 1337,
                            "user_name" => "Steve Buscemi" }}
  end

  def self.mock_activity_mixed
    { #:id              => Faker::Number.number(5),
      :recipient_id    => 238,
      "application_id" => 789,
      :activity_type   => "application",
      "event_type"     => %w[application_state_change].sample,
      :subtype         => %w[resubmitted submitted returned].sample,
      :options         => { application_id: "application_id",  
                            user_id: 1337,
                            user_name: "Steve Buscemi" } }
  end

  def self.mock_activity_csv
    "id|body|activity_type|event_type|subtype|recipient_id|sender_id|options|application_id|created_at|updated_at\n" \
    "171|this is bar|application|application_state_change|submitted|||\"{\"\"foo\"\"=>\"\"bar\"\"}\"|3|2017-10-02 18:08:44 UTC|2017-10-02 18:08:44 UTC\n" \
    "170|this is bar|application|application|created|||\"{\"\"foo\"\"=>\"\"bar\"\"}\"|3|2017-10-02 18:08:44 UTC|2017-10-02 18:08:44 UTC\n" \
    "169|this is bar|application|message|message_sent|||\"{\"\"foo\"\"=>\"\"bar\"\"}\"|3|2017-10-02 18:08:44 UTC|2017-10-02 18:08:44 UTC\n"
  end
end
