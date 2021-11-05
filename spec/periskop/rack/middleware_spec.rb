require 'rack'
require 'periskop/rack/middleware'

describe Periskop::Rack::Middleware do
  #let(:app) { ->(env) { [200, env, 'app'] } }

  class App
    def call(_)
      raise StandardError
    end
  end

  let :middleware do
    Periskop::Rack::Middleware.new(App.new, pushgateway_address: 'http://localhost:7878')
  end

  it 'captures exception on error' do
    middleware.call env_for('http://example.com?q=s')
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
