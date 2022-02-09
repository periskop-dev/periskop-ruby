require 'net/http'
require 'uri'

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

      def push_to_gateway(addr)
        if !addr.nil? && !addr.empty?
          uri = URI.parse("#{addr}/errors")
          http = Net::HTTP.new(uri.host, uri.port)
          request = Net::HTTP::Post.new(uri.request_uri, 'Content-Type' => 'application/json')
          request.body = export
          http.request(request)
        end
      end
    end
  end
end
