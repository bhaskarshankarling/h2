# H2

[![Build Status](https://travis-ci.org/kenichi/h2.svg?branch=master)](https://travis-ci.org/kenichi/h2)

H2 is a basic, _experimental_ HTTP/2 client based on the [http-2](https://github.com/igrigorik/http-2) gem.

H2 uses:

* keyword arguments (>=2.0)
* exception-less socket IO (>=2.3).

## Usage

```ruby
require 'h2'

#
# --- one-shot convenience
#

stream = H2.get url: 'https://example.com'

stream.ok?     #=> true
stream.headers #=> Hash
stream.body    #=> String
stream.closed? #=> true

client = stream.client #=> H2::Client

client.closed? #=> true

#
# --- normal connection
#

client = H2::Client.new addr: 'example.com', port: 443

stream = client.get path: '/'

stream.ok?     #=> true
stream.headers #=> Hash, method blocks until stream is closed
stream.body    #=> String, method blocks until stream is closed
stream.closed? #=> true

client.closed? #=> false unless server sent GOAWAY

stream = client.get path: '/push_promise' do |s| # H2::Stream === s
  s.on :headers do |h|
    if h['ETag'] == 'some_value']
      s.cancel! # already have 
    end
  end
end

stream.block! # blocks until this stream and any associated push streams are closed

stream.ok?     #=> true
stream.headers #=> Hash
stream.body    #=> String
stream.closed? #=> true

stream.pushes #=> Set
stream.pushes.each do |pp|
  pp.parent == stream #=> true
  pp.headers          #=> Hash
  pp.body             #=> String
end

client.goaway!
```

## CLI

For more info on using the CLI `h2` installed with this gem:

`$ h2 --help`

## Alternate Concurrency Models

Right now, h2 uses one new thread per connection. This is hardly ideal, so a
couple other models are tentatively supported out of the box:

* [celluloid](https://github.com/celluloid/celluloid)
* [concurrent-ruby](https://github.com/ruby-concurrency/concurrent-ruby)

Neither of these gems are hard dependencies. If you want to use either one, you must
have it available to your Ruby VM, most likely via Bundler, *and* require the
sub-component of h2 that will prepend and extend `H2::Client`. They are also intended
to be mutually exclusive: you can have both in your VM, but you can only use one at a
time with h2.

#### Celluloid Pool

To use a celluloid actor pool for reading from `H2::Client` connections:

```ruby
require 'h2/client/celluloid'
```

This will lazily fire up a celluloid pool, with defaults defined by Celluloid.

#### Concurrent-Ruby ThreadPoolExecutor

To use a concurrent-ruby thread pool executor for reading from `H2::Client` connections:

```ruby
require 'h2/client/concurrent'
```

This will lazily fire up a `Concurrent::ThreadPoolExecutor` with the following settings:

```ruby
procs = ::Concurrent.processor_count

min_threads: 0,
max_threads: procs,
max_queue:   procs * 5
```

## TODO

* [x] HTTPS / TLS
* [x] push promise cancellation
* [x] alternate concurrency models
* [ ] fix up CLI to be more curlish

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kenichi/h2. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
