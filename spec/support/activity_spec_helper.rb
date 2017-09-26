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
    { id:             Faker::Number.number(10),
      recipient_id:   Faker::Number.number(10),
      application_id: Faker::Number.number(5),
      activity_type:  "application",
      event_type:     %w[activity_log_event].sample,
      subtype:        %w[subtype1 subtype2 subtype3].sample,
      options:        nil }
  end

  def self.mock_activity_string
    { "id"             => Faker::Number.number(10),
      "recipient_id"   => Faker::Number.number(10),
      "application_id" => Faker::Number.number(5),
      "activity_type"  => "application",
      "event_type"     => %w[activity_log_event].sample,
      "subtype"        => %w[subtype1 subtype2 subtype3].sample,
      "options"        => nil }
  end

  def self.mock_activity_mixed
    { :id              => Faker::Number.number(10),
      :recipient_id    => Faker::Number.number(10),
      "application_id" => Faker::Number.number(5),
      :activity_type   => "application",
      "event_type"     => %w[activity_log_event].sample,
      :subtype         => %w[subtype1 subtype2 subtype3].sample,
      :options         => nil }
  end
end
