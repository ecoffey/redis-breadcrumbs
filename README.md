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

  member_of_set :id => 'resque:workers'
end
```

## Usage

No release yet :)

## Contributing

1. Fork it.
2. Create a branch (`git checkout -b my_awesome_branch`)
3. Commit your changes (`git commit -am "Added some magic"`)
4. Push to the branch (`git push origin my_awesome_branch`)
5. Send pull request
