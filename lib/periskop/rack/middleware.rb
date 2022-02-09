require 'periskop/client/collector'
require 'periskop/client/exporter'
require 'periskop/client/models'

module Periskop
  module Rack
    class Middleware
      attr_accessor :collector

      def initialize(app, options = {})
        @app = app
        @pushgateway_address = options.fetch(:pushgateway_address, nil)
        options[:collector] ||= Periskop::Client::ExceptionCollector.new
        @collector = options.fetch(:collector)

        @exporter =
          unless @pushgateway_address.nil? || @pushgateway_address.empty?
            @exporter = Periskop::Client::Exporter.new(@collector)
          end
      end

      def call(env)
        begin
          response = @app.call(env)
        rescue Exception => ex
          report_push(env, ex)
          raise(ex)
        end

        maybe_ex = framework_exception(env)
        report_push(env, maybe_ex) if maybe_ex

        response
      end

      private

      # Web framework middlewares often store rescued exceptions inside the
      # Rack env, but Rack doesn't have a standard key for it:
      #
      # - Rails uses action_dispatch.exception: https://goo.gl/Kd694n
      # - Sinatra uses sinatra.error: https://goo.gl/LLkVL9
      # - Goliath uses rack.exception: https://goo.gl/i7e1nA
      def framework_exception(env)
        env['rack.exception'] ||
          env['sinatra.error'] ||
          env['action_dispatch.exception']
      end

      def find_request(env)
        if defined?(ActionDispatch::Request)
          ActionDispatch::Request.new(env)
        elsif defined?(Sinatra::Request)
          Sinatra::Request.new(env)
        else
          ::Rack::Request.new(env)
        end
      end

      def get_http_headers(request_env)
        header_prefixes = %w[
          HTTP_
          CONTENT_TYPE
          CONTENT_LENGTH
        ].freeze

        request_env.map.with_object({}) do |(key, value), headers|
          if header_prefixes.any? { |prefix| key.to_s.start_with?(prefix) }
            headers[key] = value
          end
          headers
        end
      end

      def get_http_context(env)
        request = find_request(env)
        Periskop::Client::HTTPContext.new(request.request_method, request.url, get_http_headers(request.env), nil)
      end

      def report_push(env, maybe_ex)
        ex =
          if maybe_ex.is_a?(Exception)
            maybe_ex
          else
            RuntimeError.new(maybe_ex.to_s)
          end
        @collector.report_with_context(ex, get_http_context(env))
        @exporter&.push_to_gateway(@pushgateway_address)
      end
    end
  end
end
