# periskop-ruby

[![Build Status](https://api.cirrus-ci.com/github/soundcloud/periskop-ruby.svg)](https://cirrus-ci.com/github/soundcloud/periskop-ruby)

Ruby client for Periskop.

## Setup

With the gemspec file in the root directory of the repository, we can locally build a gem from its source code to test it out.

```
$ gem build periskop-client.gemspec
  Successfully built RubyGem
  Name: periskop-client
  Version: 0.0.1
  File: periskop-client-0.0.1.gem

$ gem install periskop-client-0.0.1.gem
Successfully installed periskop-client-0.0.1
...
1 gem installed
```

The final step is to require the gem and use it:
```
$ irb
>> require 'periskop-client'
=> true
```

## Usage example

```ruby
require 'periskop/client/collector'
require 'periskop/client/exporter'
require 'periskop/client/models'

collector = Periskop::Client::ExceptionCollector.new
exporter = Periskop::Client::Exporter.new(collector)

def div
  1 / 0
end

begin
  div
rescue Exception => e
  collector.report(e)
  http_context = Periskop::Client::HTTPContext.new('GET', 'http://example.com', nil, '{}')
  collector.report_with_context(e, http_context)
end

puts(exporter.export)
```

## Use a Rack middleware

You can use this library as a [Rack](https://github.com/rack/rack) middleware, that allow us you to capture any error happening during the life of a request. You need to use it with an instance of a [pushgateway](https://github.com/soundcloud/periskop-pushgateway/).

```ruby
require 'periskop/rack/middleware'

use Periskop::Rack::Middleware, {pushgateway_address: "http://localhost:7878"}
```

## Run tests

1. `make prepare`
2. `make test`
