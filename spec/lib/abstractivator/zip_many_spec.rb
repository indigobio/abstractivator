require 'rspec'

def zip_many(xss)
  return [] if xss.none?
  xss.reduce(xss.first.map{[]}, &method(:pushing_zip))
end

def pushing_zip(arrays, values)
  arrays.zip(values).map { |array, value| array + [value]}
end

def zip_hash(h)
  zip_many(h.values).map do |vs|
    h.keys.zip(vs).to_h
  end
end

describe 'My behaviour' do

  it 'zip 0' do
    expect(zip_many([])).to eql []
  end

  it 'zip 1' do
    expect(zip_many([
                      [1,2]
                    ])).to eql [[1], [2]]
  end

  it 'zip 2' do
    expect(zip_many([
                      [1,2],
                      [3,4]
                    ])).to eql [[1, 3], [2, 4]]
  end

  it 'zip hash' do
    h = {
      a: [1,2],
      b: [3,4],
      c: [5,6]
    }
    r = zip_hash(h)
    expect(r).to eql [
                       {a: 1, b: 3, c: 5},
                       {a: 2, b: 4, c: 6}
                     ]
  end
end
