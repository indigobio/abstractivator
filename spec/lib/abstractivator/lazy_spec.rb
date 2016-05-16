require 'rspec'
require 'abstractivator/lazy'

describe Abstractivator::Lazy do

  it 'delays a value' do
    log = []
    value = lazy { log << 'did work'; 42}
    expect(log).to eql []
    expect(value).to eql 42
    expect(log).to eql ['did work']
  end

  it 'the value is mutable' do
    value = lazy { [1] }
    expect(value).to eql [1]
    value << 2
    expect(value).to eql [1, 2]
  end

  it 'stringifies like a normal object' do
    value = lazy { 42 }
    expect(value.to_s).to eql '42'
  end

  it 'equality works like normal' do
    expect(lazy { 42 } == 42).to be true
    expect(lazy { 42 } == 99).to be false
    expect(lazy { 42 } != 42).to be false
    expect(lazy { 42 } != 99).to be true
    expect(lazy { 42 } === 42).to be true
    expect(Fixnum === lazy { 42 }).to be true
    expect(Array === lazy { 42 }).to be false
    expect(!(lazy { true })).to be false
    expect(!(lazy { false })).to be true
  end

  it 'methods work' do
    value = lazy { 1..5 }
    expect(value.size).to eql 5
  end

  describe '#inspect' do
    it 'does not force the value' do
      log = []
      value = lazy { log << 'did work'; 42}
      value.inspect
      expect(log).to eql []
    end
    it 'reveals the wrapper' do
      value = lazy { 42 }
      expect(value.inspect).to match /#<Abstractivator::Lazy:0x[0-9a-f]+>/
    end
    it 'reveals the value type if the value has already been forced' do
      value = lazy { 42 }
      value.to_s
      expect(value.inspect).to match /#<Abstractivator::Lazy:Fixnum:0x[0-9a-f]+>/
    end
  end

  context 'when the block raises an error' do
    let!(:value) { lazy { raise 'oops' } }
    it 'accessors raise the error' do
      expect { value.to_s }.to raise_error 'oops'
    end
    it 'subsequent accesses also raise the error' do
      expect { value.to_s }.to raise_error 'oops'
      expect { value.to_s }.to raise_error 'oops'
    end
  end

  it 'reflects through the wrapper' do
    value = lazy { [] }
    expect(value.class).to eql Array
    expect(value.is_a?(Array)).to be true
    expect(value.methods).to include :reverse
  end
end
