require 'rspec'
require 'abstractivator/permute'

describe Abstractivator::Permute do
  using Abstractivator::Permute

  it 'permutes' do
    result = permute(a: 1..2, b: 3..5) { |a:, b:| [a, b]}
    expect(result).to match_array [[1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5]]
  end

  it 'returns array of hashes if no block is provided' do
    result = permute(a: [1], b: [2, 3])
    expect(result).to match_array [{a: 1, b: 2},
                                   {a: 1, b: 3}]
  end

  it 'returns empty array when no variables specified' do
    expect(permute).to eql []
  end

  # checks that refinements are working as intended ...

  it 'explicit receiver not allowed' do
    expect(Object.new.respond_to?(:permute)).to be false
  end

  it 'private methods are private' do
    expect { perm(nil, nil) }.to raise_error NoMethodError
  end
end
