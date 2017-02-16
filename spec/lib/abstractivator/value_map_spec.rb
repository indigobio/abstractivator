require 'rspec'
require 'abstractivator/value_map'

describe '#value_map' do

  Foo = Struct.new(:a)

  it 'maps arrays' do
    expect([[:a, 1], [:b, 2]].value_map(&:reverse)).to eql [[1, :a], [2, :b]]
  end

  it 'maps single values' do
    expect(3.value_map(&method(:square))).to eql 9
  end

  it 'structs are treated as single values' do
    expect(Foo.new(42).value_map { |x| x.a }).to eql 42
  end

  it 'hashes are treated as single values' do
    expect({a: 1, b: 2}.value_map { |x| x[:a] }).to eql 1
  end

  it 'maps nil' do
    expect(nil.value_map(&method(:square))).to be nil
  end

  def square(x)
    x * x
  end
end
