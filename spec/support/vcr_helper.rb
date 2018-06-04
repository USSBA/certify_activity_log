require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :excon
end

RSpec.configure do |config|
  # Add VCR to all tests
  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    if options[:record] == :skip
      VCR.turned_off(&example)
    else
      name = example
             .metadata[:full_description]
             .split(/\s+/, 2)
             .join('/')
      name = underscore(name)
             .tr('.', '/')
             .gsub(%r{[^\w\/]+}, '_')
             .gsub(%r{\/$}, '')
      # puts "VCR.use_cassette(#{name}, #{options.inspect}, &example)"
      VCR.use_cassette(name, options, &example)
    end
  end
end

# File activesupport/lib/active_support/inflector/methods.rb, line 91
def underscore(camel_cased_word)
  return camel_cased_word unless /[A-Z-]|::/.match?(camel_cased_word)
  word = camel_cased_word.to_s.gsub("::".freeze, "/".freeze)
  #word.gsub!(inflections.acronyms_underscore_regex) { "#{$1 && '_'.freeze }#{$2.downcase}" }
  word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2'.freeze)
  word.gsub!(/([a-z\d])([A-Z])/, '\1_\2'.freeze)
  word.tr!("-".freeze, "_".freeze)
  word.downcase!
  word
end
