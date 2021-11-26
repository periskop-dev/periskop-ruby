require 'rack'
require 'periskop/rack/middleware'
require 'webmock/rspec'

describe Periskop::Rack::Middleware do
  class App
    def call(_)
      raise StandardError
    end
  end

  let :middleware do
    stub_request(:post, 'http://localhost:7878/errors')
    Periskop::Rack::Middleware.new(App.new, pushgateway_address: 'http://localhost:7878')
  end

  it 'captures exception on error' do
    begin
      middleware.call env_for('http://example.com?q=s', {})
    rescue StandardError
      expect(middleware.collector.aggregated_exceptions_dict.size).to eq(1)
    end
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
