require 'periskop/client/models'

def build_exception_with_context(stacktrace)
  exception_instance = Periskop::Client::ExceptionInstance.new(
    'Exception',
    'test',
    [stacktrace],
    nil
  )
  Periskop::Client::ExceptionWithContext.new(
    exception_instance,
    nil,
    Periskop::Client::SEVERITY_ERROR
  )
end

describe Periskop::Client::ExceptionWithContext do
  describe '#aggregation_key' do
    it 'generates an aggregation key for an exception instance' do
      expect(build_exception_with_context('test').aggregation_key).to eq('Exception@098f6bcd')
    end

    it 'generates different aggregation key for an exception instance without same stack trace' do
      expect(build_exception_with_context('other').aggregation_key).to_not eq('Exception@098f6bcd')
    end
  end
end

describe Periskop::Client::AggregatedException do
  describe '#add_exception' do
    it 'keeps list of latest_errors in the range of MAX_ERRORS' do
      aggregated_exception = Periskop::Client::AggregatedException.new('error@hash', Periskop::Client::SEVERITY_ERROR)
      exception_with_context = build_exception_with_context('test')
      aggregated_exception.add_exception(exception_with_context)
      expect(aggregated_exception.total_count).to eq(1)

      (0..Periskop::Client::AggregatedException::MAX_ERRORS - 1).each do |_|
        aggregated_exception.add_exception(exception_with_context)
      end
      expect(aggregated_exception.total_count).to eq(Periskop::Client::AggregatedException::MAX_ERRORS + 1)
      expect(aggregated_exception.latest_errors.size).to eq(Periskop::Client::AggregatedException::MAX_ERRORS)
    end
  end
end
