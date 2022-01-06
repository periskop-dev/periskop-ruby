require 'periskop/client/exporter'
require 'periskop/client/collector'
require 'periskop/client/models'
require 'json'
require 'timecop'

describe Periskop::Client::Exporter do
  let(:collector) { Periskop::Client::ExceptionCollector.new }
  let(:exporter) { Periskop::Client::Exporter.new(collector) }

  describe '#export' do
    before do
      raise StandardError
    rescue StandardError => e
      http_context = Periskop::Client::HTTPContext.new(
        'GET', 'http://example.com', { 'Cache-Control': 'no-cache' }, nil
      )
      Timecop.travel(Time.utc(2019, 10, 11, 12, 47, 25)) do
        collector.report_with_context(e, http_context)
      end
    end

    def get_aggregation_hash()
      if RUBY_VERSION < '3.0'
        'cfbf9f17'
      else
        '138b8e97'
      end
    end

    it 'exports to the expected format' do
      expected_json = <<HEREDOC
      {
        "target_uuid": "5d9893c6-51d6-11ea-8aad-f894c260afe5",
        "aggregated_errors": [
          {
            "aggregation_key": "StandardError@#{get_aggregation_hash()}",
            "total_count": 1,
            "severity": "error",
            "created_at": "2019-10-11T12:47:25Z",
            "latest_errors": [
              {
                "error": {
                  "class": "StandardError",
                  "message": "StandardError",
                  "stacktrace": "",
                  "cause": null
                },
                "uuid": "5d9893c6-51d6-11ea-8aad-f894c260afe5",
                "timestamp": "2019-10-11T12:47:25Z",
                "severity": "error",
                "http_context": {
                  "request_method": "GET",
                  "request_url": "http://example.com",
                  "request_headers": {
                    "Cache-Control": "no-cache"
                  },
                  "request_body": null
                }
              }
            ]
          }
        ]
      }
HEREDOC
      exported_json = JSON.parse(exporter.export)
      exported_json['aggregated_errors'][0]['latest_errors'][0]['error']['stacktrace'] = ''
      exported_json['aggregated_errors'][0]['latest_errors'][0]['uuid'] = '5d9893c6-51d6-11ea-8aad-f894c260afe5'
      exported_json['target_uuid'] = '5d9893c6-51d6-11ea-8aad-f894c260afe5'
      expect(exported_json).to eq(JSON.parse(expected_json))
    end
  end
end
