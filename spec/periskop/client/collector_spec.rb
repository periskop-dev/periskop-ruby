require 'periskop/client/collector'
require 'periskop/client/models'

describe Periskop::Client::ExceptionCollector do
  let(:collector) { Periskop::Client::ExceptionCollector.new }

  describe '#report' do
    before do
      raise StandardError
    rescue StandardError => e
      collector.report(e)
    end

    it 'adds the exception to hash of exceptions' do
      expect(collector.aggregated_exceptions_dict.size).to eq(1)
    end

    it 'has the valid exception name' do
      expect(
        collector.aggregated_exceptions_dict.values[0].latest_errors[0].exception_instance.class
      ).to eq('StandardError')
    end
  end

  describe '#report manual error' do
    before do
      collector.report(RuntimeError.new('new error'))
    end

    it 'adds the exception to hash of exceptions' do
      expect(collector.aggregated_exceptions_dict.size).to eq(1)
    end

    it 'has the valid exception name' do
      expect(
        collector.aggregated_exceptions_dict.values[0].latest_errors[0].exception_instance.class
      ).to eq('RuntimeError')
    end
  end

  describe '#report_with_context' do
    before do
      raise StandardError
    rescue StandardError => e
      http_context = Periskop::Client::HTTPContext.new('GET', 'http://example.com', nil, '{}')
      collector.report_with_context(e, http_context)
    end

    it 'adds the exception to hash of exceptions' do
      expect(collector.aggregated_exceptions_dict.size).to eq(1)
    end

    it 'has a context GET method' do
      expect(collector.aggregated_exceptions_dict.values[0].latest_errors[0].http_context.request_method).to eq('GET')
    end
  end
end
