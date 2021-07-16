# periskop-ruby
Ruby client for Periskop

### Contributing

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

### Test

1. `gem install rspec`
2. `rspec`
