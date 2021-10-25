module Periskop
  class Middleware
    def initialize(app, options = {})
      @app = app
      @pushgateway_address = options.fetch(:pushgateway_address)
      @collector = Periskop::Client::ExceptionCollector.new()
      @exporter = Periskop::Client::Exporter.new(@collector)
    end

    def call(env)
      begin
        response = @app.call(env)
      rescue => ex
        report_push(ex)
        raise(ex)
      end

      maybe_ex = framework_exception(env)
      report_push(maybe_ex) if maybe_ex

      response
    end
  end

  private

  def framework_exception(env)
    env['rack.exception'] ||
      env['sinatra.error'] ||
      env['action_dispatch.exception']
  end

  def report_push(maybe_ex)
    ex =
      if maybe_ex.is_a?(Exception)
        maybe_ex
      else
        RuntimeError.new(maybe_ex.to_s)
      end

    @collector.report(ex)
    @exporter.push_to_gateway(@pushgateway_address)
  end
end
