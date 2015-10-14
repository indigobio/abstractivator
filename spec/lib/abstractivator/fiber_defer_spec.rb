require 'rspec'
require 'abstractivator/fiber_defer'
require 'eventmachine'

describe Abstractivator::FiberDefer do
  include Abstractivator::FiberDefer

  describe '#with_fiber_defer' do
    context 'when an eventmachine reactor is not running' do
      it 'raises an error' do
        expect{with_fiber_defer}.to raise_error /reactor/
      end
    end
    context 'when an eventmachine reactor is running' do
      it 'calls the block' do
        EM.run do
          expect{|b| with_fiber_defer(&b)}.to yield_control
          EM.stop
        end
      end
      context 'when no block is provided' do
        it 'does nothing' do
          EM.run do
            with_fiber_defer
            EM.stop
          end
        end
      end
    end
  end

  describe '#fiber_defer' do
    context 'when it is called outside a with_fiber_defer block' do
      it 'raises an error' do
        expect{fiber_defer{}}.to raise_error /with_fiber_defer/
      end
    end
    context 'when it is not passed a block' do
      it 'raises an error' do
        expect{fiber_defer}.to raise_error /must be passed an action/
      end
    end
    it 'executes the block on a background thread' do
      EM.run do
        with_fiber_defer do
          main_thread = Thread.current
          executed = false
          fiber_defer do
            expect(Thread.current).to_not eql main_thread
            executed = true
          end
          expect(executed).to be true
          EM.stop
        end
      end
    end
    it 'returns the value of its block' do
      EM.run do
        with_fiber_defer do
          expect(fiber_defer{42}).to eql 42
          EM.stop
        end
      end
    end
    it 'raises an error raised by its block' do
      EM.run do
        with_fiber_defer do
          expect{fiber_defer{raise 'oops'}}.to raise_error 'oops'
          EM.stop
        end
      end
    end
  end
end