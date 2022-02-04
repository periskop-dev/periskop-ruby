require 'time'
require 'securerandom'
require 'digest'

module Periskop
  module Client
    SEVERITY_INFO = "info"
    SEVERITY_WARNING = "warning"
    SEVERITY_ERROR = "error"
    # ExceptionInstance has all metadata of a reported exception
    class ExceptionInstance
      attr_accessor :class, :message, :stacktrace, :cause

      def initialize(cls, message, stacktrace, cause)
        @class = cls
        @message = message
        @stacktrace = stacktrace
        @cause = cause
      end

      def self.from_exception(exception)
        ExceptionInstance.new(
          exception.class.name,
          exception.message,
          exception.backtrace,
          get_cause(exception)
        )
      end

      def self.get_cause(exception)
        if RUBY_VERSION > '2.0'
          if exception.cause.is_a?(Exception)
            return ExceptionInstance.from_exception(exception.cause)
          end
        end

        nil
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

    # HTTPContext represents data from HTTP context of an exception
    class HTTPContext
      attr_accessor :request_method

      def initialize(request_method, request_url, request_headers, request_body)
        @request_method = request_method
        @request_url = request_url
        @request_headers = request_headers
        @request_body = request_body
      end

      def as_json(_options = {})
        {
          request_method: @request_method,
          request_url: @request_url,
          request_headers: @request_headers,
          request_body: @request_body
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end

    # ExceptionWithContext represents a reported exception with HTTP context
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

      # Generates the aggregation key with a hash using the last MAX_TRACES
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

    # AggregatedException represents the aggregation of a group of exceptions
    class AggregatedException
      attr_accessor :latest_errors, :total_count

      MAX_ERRORS = 10

      def initialize(aggregation_key, severity)
        @aggregation_key = aggregation_key
        @latest_errors = []
        @total_count = 0
        @severity = severity
        @created_at = Time.now.utc.iso8601
      end

      # Add exception to the list of latest errors up to MAX_ERRORS
      def add_exception(exception_with_context)
        if @latest_errors.size >= MAX_ERRORS
          @latest_errors.shift
        end
        @latest_errors.push(exception_with_context)
        @total_count += 1
      end

      def as_json(_options = {})
        {
          aggregation_key: @aggregation_key,
          created_at: @created_at,
          total_count: @total_count,
          severity: @severity,
          latest_errors: @latest_errors
        }
      end

      def to_json(*options)
        as_json(*options).to_json(*options)
      end
    end

    # Payload represents the aggregated structure of errors
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
