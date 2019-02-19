# Changelog
All notable changes to this project will be documented in this file.

## [1.5.1] - 2019-02-28
### shared-services-sprint-63
### Changed
  - HUB-1821
    - Updates documentation

## [1.5.0] - 2019-01-18
### shared-services-sprint-60
### Changed
  - Activity resource supports v1, v2, and v3 of activity API

## [1.4.0] - 2018-09-30
### shared-services-sprint-52
### Added
  - HUB-1576
    - Added api_key to configuration in anticipation of AWS API Gateway

## [1.3.2] - 2018-09-14
### shared-services-sprint-51
### Changed
  - HUB-1583
    - version bump for deployment to geminabox

## [1.3.1] - 2018-04-23
### Changed
  - Hotfix to actually allow activity_type to be sent to the API

## [1.3.0] - 2017-12-08
### shared-services-sprint-31
### Added
  - HUB-1000
    - Adds configuration for column_separator when exporting as CSV

## [1.2.0] - 2017-11-10
### shared-services-sprint-29
### Added
  - HUB-919:
    - Added custom configuration of `excon_timeout` and makes it available to be configured by gem user.
    - Sets Excon connection values for `connect_timeout`, `read_timeout` and `write_timeout` to equal value of `excon_timeout`
    - Added logger functionality to the gem, refer to README for more details about configuration.


## [1.1.0] 2017-10-13
### shared-services-sprint-27
### Added
  - HUB-849
    - Added the `export` method and tests to allow for downloading a csv of activity log for a certain application.  Refer to `README` for additional details.

## [1.0.0] - 2017-09-28
### shared-services-sprint-26
### Added
- New gem to interact with the activity log API.
