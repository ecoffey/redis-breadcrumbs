[![Build Status](https://travis-ci.org/ecoffey/redis-breadcrumbs.png)](https://travis-ci.org/ecoffey/redis-breadcrumbs)

## Redis and key tracking

Redis is a bit different than a lot of other "data stores". This also means that thinking about ownership management
is a little bit different in redis.

Typically one domain "concept" will have different relationships with multiple keys.

Take Resque for example. A individual worker in Resque interacts with the following keys:

* The worker id is a member of `resque:workers`
* It creates `resque:worker:<id>` and `resque:worker:<id>:started`

When the worker shuts down it must remove its id from `resque:workers` and delete the other two keys.

With breadcrumbs you could describe those relationships thusly:

```ruby
class WorkerBreadcrumb < Redis::Breadcrumb
  owns 'resque:worker:<id>'
  owns 'resque:worker:<id>:started'

  member_of_set '<id>' => 'resque:workers'
end
```

## Installation

Either

`gem install redis-breadcrumbs`

or add the following to your Gemfile

`gem "redis-breadcrumbs", "~> 0.0.2"`

## Usage

Create your breadcrumb; we'll continue with the Resque example:

```ruby
class WorkerBreadcrumb < Redis::Breadcrumb
  owns 'resque:worker:<id>'
  owns 'resque:worker:<id>:started'

  member_of_set '<id>' => 'resque:workers'
end
```

Keys that have `<...>` snippets in them are **templates**.  When you call `track!` or `clean!`,
the Breadcrumb will expect an object that responds to symbols in between the brackets.

You can also specify a key to track keys in, with `tracked_in 'resque:worker:<id>:tracking'`_

Using `tracked_in` will let your breadcrumb remember how to clean up keys, that are not currently
defined in the class (because of code changes, etc).

Breadcrumb also needs to be told about a redis connection:

```ruby
# Breadcrumb always operates on the 'raw' client,
# so it will 'unwrap' Redis::Namespace

Redis::Breadcrumb.redis = Resque.redis
```

When you're ready to start tracking keys (say after the worker finished booting) you can
do:

```ruby
WorkerBreadcrumb.track!(self)
```

And when you're ready to clean up keys (say when working is shutting down, or in a clean up rake task)

```ruby
WorkerBreadcrumb.clean!(self)
```

## Contributing

1. Fork it.
2. Create a branch (`git checkout -b my_awesome_branch`)
3. Commit your changes (`git commit -am "Added some magic"`)
4. Push to the branch (`git push origin my_awesome_branch`)
5. Send pull request
