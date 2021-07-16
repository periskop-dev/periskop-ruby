require 'periskop/client/models'
require 'json'
require 'securerandom'

module Periskop
  module Client
    class ExceptionCollector
      def initialize
        @aggregated_exceptions = {}
        @uuid = SecureRandom.uuid
      end

      def aggregated_exceptions
        Payload.new(@aggregated_exceptions.values, @uuid)
      end

      # Report an exception
      # Params:
      # exception:: captured exception
      def report(exception)
        exception_instance = ExceptionInstance.new(
          exception.class.name,
          exception.message,
          exception.backtrace,
          exception.cause
        )
        exception_with_context = ExceptionWithContext.new(
          exception_instance,
          nil,
          'error'
        )
        aggregation_key = exception_with_context.aggregation_key()

        unless @aggregated_exceptions.key?(aggregation_key)
          aggregated_exception = AggregatedException.new(
            aggregation_key,
            'error'
          )
          @aggregated_exceptions.store(aggregation_key, aggregated_exception)
        end
        aggregated_exception = @aggregated_exceptions[aggregation_key]
        aggregated_exception.add_exception(exception_with_context)
      end
    end
  end
end
