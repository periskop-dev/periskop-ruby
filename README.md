# periskop-ruby
Ruby client for Periskop

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

### Run tests

1. `gem install rspec`
2. `rspec`
