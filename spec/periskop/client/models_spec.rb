require 'periskop/client/models'

describe Periskop::Client::ExceptionWithContext do
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
      'error'
    )
  end
  describe '#aggregation_key' do
    it 'generates an aggregation key for an exception instance' do
      expect(build_exception_with_context('test').aggregation_key).to eq('Exception@098f6bcd')
    end

    it 'generates different aggregation key for an exception instance without same stack trace' do
      expect(build_exception_with_context('other').aggregation_key).to_not eq('Exception@098f6bcd')
    end
  end
end
