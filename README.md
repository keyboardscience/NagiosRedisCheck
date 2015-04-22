# NagiosRedisCheck
Nagios Command Plugin to monitor Redis

## Usage
There are *currently* three check commands provided by this plugin. This plugin covers:
* Redis database size
* Redis memory utilization
* Redis sidekiq statistics (dead, retry, schedule)

Helps are provided by each executable when run with `-h` or `--help` flags.

## Setup

### Prerequisites
* Ruby (version > 2.0.x is helpful to avoid compatability issues)
* Bundler

### Procedure
1. `sudo mkdir -p /usr/local/nagios/plugins`
1. `git clone https://github.com/keyboardscience/nagiosredischeck.git /usr/local/nagios/plugins`
1. `bundle install`

## Credit
This plugin uses NagiosPlugin framework produced by [Björn Albers](https://github.com/bjoernalbers/nagiosplugin) and provided by MITv3.
