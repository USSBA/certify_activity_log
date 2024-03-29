# CertifyActivityLog
Thin wrapper for the [Certify Activity Log API](https://github.com/USSBA/activity-api) to handle basic GET and POST operations for activity log entries.

#### Table of Contents
- [Installation](#user-content-installation)
- [Configuration](#user-content-configuration)
- [Methods](#user-content-methods)
- [Pagination](#user-content-pagination)
- [Error Handling](#user-content-error-handling)
- [Logging](#user-content-logging)
- [Development](#user-content-development)
- [Publishing](#user-content-publishing)
- [Tests](#tests)
- [Changelog](#changelog)
- [License](#license)
- [Contributing](#contributing)
  - [Code of Conduct](#code-of-conduct)
- [Security Issues](#security-issues)

## Installation

### Pulling from private geminabox (preferred)

Ensure you have the credentials configured with bundler, then add the following to your Gemfile:
```
source 'https://<domain-of-our-private-gem-server>/' do
  gem 'certify_activity_log'
end
```

### Install from GitHub

Add the following to your Gemfile to bring in the gem from GitHub:

```
gem 'certify_activity_log', git: 'git@github.com:USSBA/certify_activity_log.git', branch: 'develop'
```

This will pull the head of the develop branch in as a gem.  If there are updates to the gem repository, you will need to run `bundle update certify_activity_log` to get them.

* Clone this repository
* Add it to the Gemfile with the path:

```
gem 'certify_activity_log', path: '<path-to-the-gem-on-your-system>'
```

## Configuration
Within the host application, set the Certify Activity Log API URL in `config/initializers`, you probably also want to include a `user.yml` under `config` to be able to specify the URL based on your environment.

```
CertifyActivityLog.configure do |config|
  config.api_key = "your_api_key"
  config.api_url = "http://localhost:3000"
  config.activity_api_version = 1
  config.excon_timeout = 5
end
```
The `api_key` is currently unused, but we anticipate adding in an API Gateway layer in the future.

With [v1.2.0](CHANGELOG.md#120---2017-11-10), the default Excon API connection timeout was lowered to `20 seconds`. The gem user can also provide a timeout value in seconds as shown above in the `configure` block.  This value is used for the Excon parameters `connect_timeout`, `read_timeout`, and `write_timeout`.

## Methods
Refer to the [Certify Activity Log API](https://github.com/USSBA/activity-api) for more complete documentation and detailed examples of method responses.

Note: The Activity Log API has multiple versions that support different parameters. For example, v3 may require an `application_uuid` instead of an `application_id`. Refer to the API documentation to know which parameters to use depending on the version.

### Activity Log
| Method | Description |
| ------ | ----------- |
| `CertifyActivityLog::Activity.where({application_id: 1})` | Query for all activity log entries |
| `CertifyActivityLog::Activity.create({ activity_type: <string>, event_type: <string>, subtype: <string>, recipient_id: <int>, application_id <int>, options: <hash> })` | Create a new activity log entry. Refer to https://github.com/USSBA/activity-api/ for valid `activity_type`, `event_type`, `subtype`, and `options` values |
| `CertifyActivityLog::Activity.export(application_id: 1)` | Get a delimited string of activities. The `column_separator` can be configured in `certify_activity_log/configuration.rb`. The default is `|` |

## Pagination
All lists of activities are paginated by default.  To change the number of items per page, or go to a specific page, include the following optional parameters:
- `page`: the page requested
- `per_page`: the number of items to be included on a page

Responses will include pagination information, including the following:
- `current_page`: the current page number
- `per_page`: the number of items per page
- `total_entries`: the total number of items that match the current search

## Error Handling

The Gem handles a few basic errors including:

* Bad Request - Raised when API returns the HTTP status code 400
* NotFound - Raised when API returns the HTTP status code 404
* InternalServerError - Raised when API returns the HTTP status code 500
* ServiceUnavailable - Raised when API returns the HTTP status code 503

Otherwise the gem will return more specific errors from the API. Refer to the API Docs for details around the specific error.

A typical error will look something like this:
```
{:body=>{"message"=>"No user found"}, :status=>404}
```

## Logging
Along with returning status error messages for API connection issues, the gem will also log connection errors.  The default behavior for this is to use the built in Ruby `Logger` and honor standard log level protocols.  The default log level is set to `debug` and will output to `STDOUT`.  This can also be configured by the gem user to use the gem consumer application's logger, including the app's environment specific log level.
```
# Example implementation for a Rails app
CertifyActivityLog.configure do |config|
  config.logger = Rails.logger
  config.log_level = Rails.configuration.log_level
end
```

## Development
After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

Use `bin/console` to access the pry console and add the API URL to the gem's config to be able to correctly test commands:
```
CertifyActivityLog.configuration.api_url="http://localhost:3000"
```
While working in the console, you can run `reload!` to reload any code in the gem so that you do not have to restart the console.  This should not reset the manual edits to the `configuration` as noted above.

## Publishing
To release a new version:

  1. Bump the version in lib/\*/version.rb
  1. Merge into `master` (optional)
  1. Push a tag to GitHub in the form: `X.Y.Z` or `X.Y.Z.pre.myPreReleaseTag`

At this point, our CI process will kick-off, run the tests, and push the built gem into our Private Gem server.

## Tests
### RSpec Tests

 To run the test suite, simply run:
```
rspec
```

 or with verbose output:
```
rspec -f d
```

 To view the coverage report, open
```
coverage/index.html
```

 ### Rubocop
```
rubocop -D
```

 #### Poirot Secrets Testing
A secrets pattern file `poirot-patterns.txt` is included with the app to assist with running [Poirot](https://github.com/emanuelfeld/poirot) to scan commit history for secrets.  It is recommended to run this only the current branch only:
```
  poirot --patterns poirot-patterns.txt --revlist="develop^..HEAD"
```
Poirot will return an error status if it finds any secrets in the commit history between `HEAD` and develop.  You can correct these by: removing the secrets and squashing commits or by using something like BFG.

 Note that Poirot is hardcoded to run in case-insensitive mode and uses two different regex engines (`git log --grep` and a 3rd-party Python regex library https://pypi.python.org/pypi/regex/ ). Refer to Lines 121 and 195 in `<python_path>/site-packages/poirot/poirot.py`. The result is that the 'ssn' matcher will flag on: 'ssn', 'SSN', or 'ssN', etc., which also finds 'className', producing false positive errors in the full rev history.  Initially we included the `(?c)` flag in the SSN matchers: `.*(ssn)(?c).*[:=]\s*[0-9-]{9,11}` however this is not compatible with all regex engines and causes an error in some cases.  During the `--revlist="all"` full history Poirot runs, this pattern failed silently with the `git --grep` engine and therefore did not actually run.  During the `--staged` Poirot runs, this pattern fails with a stack trace with the `pypi/regex` engine. The `(?c)` pattern has been removed entirely and so the `ssn` patterns can still flag on false positives like 'className'.

## Changelog
Refer to the changelog for details on API updates. [CHANGELOG](CHANGELOG.md)

## License
Certify Activity is licensed permissively under the Apache License v2.0.
A copy of that license is distributed with this software.

## Contributing
We welcome contributions. Please read [CONTRIBUTING](CONTRIBUTING.md) for how to contribute.

### Code Of Conduct

We strive for a welcoming and inclusive environment for the Certify Activity project.

Please follow this guidelines in all interactions:

1. Be Respectful: use welcoming and inclusive language.
2. Assume best intentions: seek to understand other's opinions.

## Security Issues
Please do not submit an issue on GitHub for a security vulnerability. Please contact the development team through the Certify Help Desk at [help@certify.sba.gov](mailto:help@certify.sba.gov).

Be sure to include all the pertinent information.

<sub>The agency reserves the right to change this policy at any time.</sub>

