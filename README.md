# Loggery Gem

Make your Rails app produce [Logstash](https://www.elastic.co/products/logstash) compatible log
files that can be used for structured, centralized logging in
[Kibana](https://www.elastic.co/products/kibana).

This is a convenience gem that heavily builds on previous work by
[Lograge](https://github.com/roidrage/lograge) by
[roidrage](https://github.com/dwbutler/logstash-logger) and
[logstash-logger](https://github.com/dwbutler/logstash-logger) by
[dwbutler](https://github.com/dwbutler). It mainly connects these gems and sets some useful
defaults.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'loggery'
```

And then execute:

    $ bundle

### Basic Rails integration

To enable, add

```ruby
config.loggery.enabled = true
```

to your `config/application.rb` or to the environment specific `config/staging.rb` and/or
`config/production.rb`.

In this basic setup, Loggery will save your log output to
`log/logstash-<rails-env>.log` in JSON format. It will also:
* use [lograge](https://github.com/roidrage/lograge) to create a single-line log entry for every
  Rails request including the db / view / total duration, controller name, action, http status, etc...
* add the process PID to every log line
* add the request ID to every HTTP request, to easily follow the log trace of any single request.

### Custom logging

In addition to logging strings like any normal Rails app

```ruby
Rails.logger.info "OMG something just happened!"
```

You can now also log hashes with additional information:

```ruby
Rails.logger.info message: "OMG something just happened!", reason: "Foo servive not available", context:
some_hash.inspect, attempt: attempt_counter, time_taken: your_time_measurement
```

This allows you to give your logs more context about the thing you were trying to do, the state of
input variables, etc...

The following context attribute names should be avoided, because they are used by other tools in the
chain. Using those will result in an exception to make sure you notice during development and
testing:
* type
* uid
* _id
* _type
* _source
* _all
* _parent
* _fieldnames
* _routing
* _index
* _size
* _timestamp
* _ttl

### Add user metadata to logs

If you would like to enrich your log records with information about the active user, add this to
your `ApplicationController`:

```ruby
include Loggery::Controller::LoggingContext

def loggery_log_context
  {
    user_id: current_user&.id,
    user_email: current_user&.email
  }
end
```

The above example assumes you would like to log the `id` and `email` of your user. You can provide a
method `loggery_log_context` to include whichever additional information from your controllers you
would like to add to your log records.

### Sidekiq

If you're using Sidekiq you can enable structured logging in sidekiq by adding these lines to
`config/initializers/sidekiq.rb`:

```ruby
Loggery.setup_sidekiq(config)
```

This will make sure that useful sidekiq-metadata is added to your log lines to make tracing job
executions easier. The added info is:
* sidekiq job-id
* sidekiq queue
* thread-id
* worker name
* worker arguments
* retry count
* process PID


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/liefery/loggery-gem. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

