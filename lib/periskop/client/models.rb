require 'time'
require 'securerandom'
require 'digest'

module Periskop
  module Client
    class ExceptionInstance
      attr_accessor :class, :message, :stacktrace, :cause

      def initialize(cls, message, stacktrace, cause)
        @class = cls
        @message = message
        @stacktrace = stacktrace
        @cause = cause
      end

      def as_json(_options = {})
        {
          class: @class,
          message: @message,
          stacktrace: @stacktrace,
          cause: @cause
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end

    class HTTPContext
      attr_accessor :request_method

      def initialize(request_method, request_url, request_headers, request_body)
        @request_method = request_method
        @request_url = request_url
        @request_headers = request_headers
        @request_body = request_body
      end
    end

    class ExceptionWithContext
      attr_accessor :exception_instance, :http_context

      NUM_HASH_CHARS = 8
      MAX_TRACES = 5

      def initialize(exception_instance, http_context, severity)
        @exception_instance = exception_instance
        @http_context = http_context
        @severity = severity
        @uuid = SecureRandom.uuid
        @timestamp = Time.now.utc.iso8601
      end

      def aggregation_key
        stacktrace_head = @exception_instance.stacktrace.first(MAX_TRACES).join('')
        error_hash = Digest::MD5.hexdigest(stacktrace_head)[0..NUM_HASH_CHARS - 1]
        "#{@exception_instance.class}@#{error_hash}"
      end

      def as_json(_options = {})
        {
          error: @exception_instance,
          http_context: @http_context,
          severity: @severity,
          uuid: @uuid,
          timestamp: @timestamp
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end

    class AggregatedException
      attr_accessor :latest_errors

      def initialize(aggregation_key, severity)
        @aggregation_key = aggregation_key
        @latest_errors = []
        @total_count = 0
        @severity = severity
      end

      def add_exception(exception_with_context)
        @latest_errors.push(exception_with_context)
        @total_count += 1
      end

      def as_json(_options = {})
        {
          aggregation_key: @aggregation_key,
          total_count: @total_count,
          severity: @severity,
          latest_errors: @latest_errors
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end

    class Payload
      def initialize(aggregated_errors, target_uuid)
        @aggregated_errors = aggregated_errors
        @target_uuid = target_uuid
      end

      def as_json(_options = {})
        {
          aggregated_errors: @aggregated_errors,
          target_uuid: @target_uuid
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end
  end
end
