require 'rspec'
require 'abstractivator/exception_ext'
require 'stringio'

describe Exception do
  describe '#print_full_trace' do
    it 'prints the full trace including causes' do
      io = StringIO.new
      begin
        begin
          raise ArgumentError, 'x must not be nil'
        rescue => e
          raise 'there was an error'
        end
      rescue => e
        e.print_full_trace(io)
      end
      expect(io.string).to match /RuntimeError: there was an error.*Caused by.*ArgumentError: x must not be nil/m
    end
  end
end
