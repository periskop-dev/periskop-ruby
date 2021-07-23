module Periskop
  module Client
    # Exporter exposes in json format all collected exceptions from the specified `collector`
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
