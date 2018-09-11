# CertifyActivityLog

This is a thin wrapper for the [Certify Activity Log API](https://github.com/USSBA/activity-api) to handle basic GET and POST operations for activity log entries.


#### Table of Contents
- [Installation](#user-content-installation)
- [Usage](#user-content-usage)
    - [Configuration](#user-content-configuration)
    - [Activity Log](#user-content-activity-log)
- [Error Handling](#user-content-error-handling)
- [Logging](#logging)
- [Pagination](#user-content-pagination)
- [Export Activity Log](#activity-log-export)
- [Development](#user-content-development)
- [Publishing](#user-content-publishing)
- [Changelog](#changelog)

## Installation

There are three options you can use to install the gem. Pulling from the private sba-one gem server, building it manually, or installing directly from GitHub.

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
gem 'certify_activity_log', git: 'git@github.com:USSBA/certify_activity_log.git', branch: 'develop' # Certify activity log service
```

This will pull the head of the develop branch in as a gem.  If there are updates to the gem repository, you will need to run `bundle update certify_activity_log` to get them.

### Building it manually

* Pull down the latest branch for the gem
* `bundle install` to build it
* You can run tests `rspec` to make sure it built okay.
* Then `rake build` to build the gem, this builds the .gem file in /pkg
* Jump over to the folder of the the app where you want to use them and follow the instructions below within that app/repo, for example, if working with the [Shared-Services Prototype](https://github.com/USSBA/shared-services-prototype):
  * Copy the .gem into the folder `vendor/gems/certify_activity_log`
  * In the app where you want to use the gem, do `gem install <path to gem>` e.g. `gem install vendor/gems/certify_activity_log/certify_activity_log-0.1.0.gem`
  * add `gem 'certify_activity_log'` to your Gemfile
  * `bundle install`
  * If this worked correctly, you should see `certify_activity_log` in your `Gemfile.lock`

### GemInABox

Having acquired the readtoken to the SBA geminabox server, add it to your bundle config via `bundle config geminabox.sba-one.net readtoken:readtoken`.

To relase a new version to geminabox, simply tag the repository with a tag in the form vX.Y.Z.  This will trigger an AWS CodeBuild process to build and deploy the gem to geminabox.

To use the gem from geminabox, add the following to your `Gemfile`:
```
group :ussba, :default do
  source 'https://geminabox.sba-one.net/' do
    gem 'certify_activity_log'
  end
end
```

### Install gem from GitHub

Alternatively, you can add the following to your Gemfile to bring in the gem from GitHub:

```
gem 'certify_activity_log', git: 'git@github.com:USSBA/certify_activity_log.git', branch: 'develop' # Certify activity log service
```

This will pull the head of the develop branch in as a gem.  If there are updates to the gem repository, you will need to run `bundle update certify_activity_log` to get them.

## Usage

### Configuration
Set the activity log API URL in your apps `config/initializers` folder, you probably also want to include an `activity_log.yml` under `config` to be able to specify the URL based on your environment.

```
CertifyActivityLog.configure do |config|
  config.api_url = "http://localhost:3005"
  config.activity_api_version = 1
  config.excon_timeout = 5
end
```

With [v1.2.0](CHANGELOG.md#120---2017-11-10), the default Excon API connection timeout was lowered to `20 seconds`. The gem user can also provide a timeout value in seconds as shown above in the `configure` block.  This value is used for the Excon parameters `connect_timeout`, `read_timeout`, and `write_timeout`.

### Activity Log

#### Finding (GET) Activity Log Entries
* calling `CertifyActivityLog::Activity.where({application_id: 1})` will query for all activity log entries for application_id = 1
* Calling the `.where` method with empty or invalid parameters will result in an error (see below)

#### Creating (POST) Activity Log Entries
* to create a new activity, the following parameters are required:
```
  CertifyActivityLog::Activity.create({
    activity_type: <string>,  # e.g., 'application'
    event_type: <string>,
    subtype: <string>
    recipient_id: <int>,
    application_id <int>,
    options: <hash>
  })
```
* and with optional parameters
```
  CertifyActivityLog::Activity.create({
    activity_type: <string>,
    event_type: <string>,
    subtype: <string>
    recipient_id: <int>,
    application_id <int>,
    options: <hash>
  })
```
* refer to https://github.com/USSBA/activity-api/ for valid `activity_type`, `event_type`, `subtype`, and `options` values
* This will return a JSON hash with a `body` containing the data of the activity along with `status` of 201.
* Calling the `.create` method with empty or invalid parameters will result in an error (see below)

#### Updating (PUT) Activity Log Entries
Once created, activity log entries cannot be modified.

#### Finding (GET) Activity Log
* calling `CertifyActivityLog::Activity.where({application_id: 1})` will return all activity log entries for the application with id = 1
* Calling the `.where` method with empty or invalid parameters will result in an error (see below)

#### Exporting Activity Log as CSV
* calling `CertifyActivityLog::Activity.export(application_id: 1)` will return a delimited string of the activities
* the `column_separator` can be configured in `certify_activity_log/configuration.rb`
** Default is "|". Only one character can be used for delimiting


## Error Handling
* Calling a Gem method with no or empty parameters, e.g.:
CertifyActivityLog::Activity.where   {}
CertifyActivityLog::Activity.create {}
```
will return a bad request:
`{body: "Bad Request: No parameters submitted", status: 400}`
* Calling a Gem method with invalid parameters:
```
CertifyActivityLog::Activity.where   {foo: 'bar'}
CertifyActivityLog::Activity.create {foo: 'bar'}
```
will return an unprocessable entity error:
`{body: "Unprocessable Entity: Invalid parameters submitted", status: 422}`
* Any other errors that the Gem experiences when connecting to the API will return a service error and the Excon error class:
`    {body: "Service Unavailable: There was a problem connecting to the activity log API. Type: Excon::Error::Socket", status: 503}`

## Logging
Along with returning status error messages for API connection issues, the gem will also log connection errors.  The default behavior for this is to use the built in Ruby `Logger` and honor standard log level protocols.  The default log level is set to `debug` and will output to `STDOUT`.  This can also be configured by the gem user to use the gem consumer application's logger, including the app's environment specific log level.
```
# example implementation for a Rails app
CertifyActivityLog.configure do |config|
  config.logger = Rails.logger
  config.log_level = Rails.configuration.log_level
end
```

## Pagination
All lists of activities are paginated by default.  To change the number of items per page, or go to a specific page, include the following optional parameters:
- `page`: the page requested
- `per_page`: the number of items to be included on a page

Responses will include pagination information, including the following:
- `current_page`: the current page number
- `per_page`: the number of items per page
- `total_entries`: the total number of items that match the current search

## Export Activity Log
The gem provides a method for calling the `export` route of the Activity Log API: `CertifyActivityLog::Activity.export`.  At minimum, this method requires that an `application_id` is provided as a parameter.  Providing no parameters or no `application_id` will return a 400 'Bad Request'.  A correctly formatted request will return the API response body which will be a string of the pipe delimited content which can be rendered as `"Content-Type => "text/csv"`.

## Development
Use `rake console` to access the pry console and add the activity-log API URL to the gem's config to be able to correctly test commands:
```
CertifyActivityLog.configuration.api_url="http://localhost:3005"
```
While working in the console, you can run `reload!` to reload any code in the gem so that you do not have to restart the console.  This should not reset the manual edits to the `configuration` as noted above.

## Publishing
To release a new version:

  1. Bump the version in lib/\*/version.rb
  1. Merge into `master` (optional)
  1. Push a tag to GitHub in the form: `X.Y.Z` or `X.Y.Z.pre.myPreReleaseTag`

At this point, our CI process will kick-off, run the tests, and push the built gem into our Private Gem server.

## Changelog
Refer to the changelog for details on API updates. [CHANGELOG](CHANGELOG.md)
