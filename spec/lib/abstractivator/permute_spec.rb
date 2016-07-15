require 'rspec'
require 'abstractivator/permute'

describe Abstractivator::Permute do
  include Abstractivator::Permute

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
end
