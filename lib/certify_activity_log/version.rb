module CertifyActivityLog
  module VERSION
    MAJOR = 1
    MINOR = 2
    PATCH = 1
    PRE_RELEASE = "".freeze # e.g., "-beta"

    STRING = ([MAJOR, MINOR, PATCH].join('.') + PRE_RELEASE).freeze
  end
end
