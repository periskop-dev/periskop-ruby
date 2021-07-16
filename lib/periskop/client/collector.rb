require 'periskop/client/models'
require 'json'
require 'securerandom'

module Periskop
  module Client
    class ExceptionCollector
      def initialize
        @aggregated_exceptions_dict = {}
        @uuid = SecureRandom.uuid
      end

      attr_reader :aggregated_exceptions_dict

      def aggregated_exceptions
        Payload.new(@aggregated_exceptions_dict.values, @uuid)
      end

      # Report an exception
      # Params:
      # exception:: captured exception
      def report(exception)
        add_exception(exception, nil)
      end

      # Report an exception with context
      # Params:
      # exception:: captured exception
      # context:: HTTP context of the exception
      def report_with_context(exception, context)
        add_exception(exception, context)
      end

      private

      def add_exception(exception, context)
        exception_instance = ExceptionInstance.new(
          exception.class.name,
          exception.message,
          exception.backtrace,
          exception.cause
        )
        exception_with_context = ExceptionWithContext.new(
          exception_instance,
          context,
          'error'
        )
        aggregation_key = exception_with_context.aggregation_key()

        unless @aggregated_exceptions_dict.key?(aggregation_key)
          aggregated_exception = AggregatedException.new(
            aggregation_key,
            'error'
          )
          @aggregated_exceptions_dict.store(aggregation_key, aggregated_exception)
        end
        aggregated_exception = @aggregated_exceptions_dict[aggregation_key]
        aggregated_exception.add_exception(exception_with_context)
      end
    end
  end
end
