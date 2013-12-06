# Simple HTTP Monitor

Script for monitoring website uptime status.

It should alerts via e-mail when the site has been down for configured number of consecutive tries.
Send up notification once the site comes up again. The notification contains the reason of the last error.

What does it mean "site is down?".
- incorrect HTTP response code
- response is not within desired time limits

## Installation

Add this line to your application's Gemfile:

    gem 'simple_http_monitor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simple_http_monitor

## Usage

TODO: Write usage instructions here
