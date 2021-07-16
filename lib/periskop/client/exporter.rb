module Periskop
  module Client
    class Exporter
      def initialize(collector)
        @collector = collector
      end

      def export
        @collector.aggregated_exceptions.to_json
      end
    end
  end
end
