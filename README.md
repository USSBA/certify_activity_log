# CertifyActivityLog

This is a thin wrapper for the [Certify Activity Log API](https://github.com/SBA-ONE/activity-api) to handle basic GET and POST operations for activity log entries.


#### Table of Contents
- [Installation](#user-content-installation)
- [Usage](#user-content-usage)
    - [Configuration](#user-content-configuration)
    - [Activity Log](#user-content-activity-log)
- [Error Handling](#user-content-error-handling)
- [Pagination](#user-content-pagination)
- [Export Activity Log](#activity-log-export)
- [Development](#user-content-development)
- [Changelog](#changelog)

## Installation

There are two options you can use to install the gem. Building it manually, or installing from GitHub.

### Install from GitHub

Add the following to your Gemfile to bring in the gem from GitHub:

```
gem 'certify_activity_log', git: 'git@github.com:SBA-ONE/certify_activity_log.git', branch: 'develop' # Certify activity log service
```

This will pull the head of the develop branch in as a gem.  If there are updates to the gem repository, you will need to run `bundle update certify_activity_log` to get them.

### Building it manually

* Pull down the latest branch for the gem
* `bundle install` to build it
* You can run tests `rspec` to make sure it built okay.
* Then `rake build` to build the gem, this builds the .gem file in /pkg
* Jump over to the folder of the the app where you want to use them and follow the instructions below within that app/repo, for example, if working with the [Shared-Services Prototype](https://github.com/SBA-ONE/shared-services-prototype):
  * Copy the .gem into the folder `vendor/gems/certify_activity_log`
  * In the app where you want to use the gem, do `gem install <path to gem>` e.g. `gem install vendor/gems/certify_activity_log/certify_activity_log-0.1.0.gem`
  * add `gem 'certify_activity_log'` to your Gemfile
  * `bundle install`
  * If this worked correctly, you should see `certify_activity_log` in your `Gemfile.lock`

## Usage

### Configuration
Set the activity log API URL in your apps `config/initializers` folder, you probably also want to include an `activity_log.yml` under `config` to be able to specify the URL based on your environment.

```
CertifyActivityLog.configure do |config|
  config.api_url = "http://localhost:3005"
  config.activity_api_version = 1
end
```

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

## Error Handling
* Calling a Gem method with no or empty parameters, e.g.:
```
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
Use `rake console` to access the pry console.
To test API calls with the gem within its console, you will need to specify the api url root for the corresponding API:
```
CertifyActivityLog.configuration.api_url="http://localhost:3005"
```
While working in the console, you can run `reload!` to reload any code in the gem so that you do not have to restart the console.  This should not reset the manual edits to the `configuration` as noted above.

## Changelog
Refer to the changelog for details on API updates. [CHANGELOG](CHANGELOG.md)
