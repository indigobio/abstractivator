require 'rspec'
require 'abstractivator/hash_permuter'

module Abstractivator
  describe HashPermuter do
    include HashPermuter
    FixedRange = HashPermuter::FixedRange
    SteppedRange = HashPermuter::SteppedRange
    FreeVar = HashPermuter::FreeVar

    describe '#permute' do
      it 'permutes' do
        input = {
          a: SteppedRange.new(1, 2, 2),
          b: SteppedRange.new(3, 5, 3),
          c: 42
        }
        result = HashPermuter.permute_hash(input)
        expect(result).to eql [{a: 1.0, b: 3.0, c: 42},
                               {a: 1.0, b: 4.0, c: 42},
                               {a: 1.0, b: 5.0, c: 42},
                               {a: 2.0, b: 3.0, c: 42},
                               {a: 2.0, b: 4.0, c: 42},
                               {a: 2.0, b: 5.0, c: 42}]
      end
    end

    describe FixedRange do
      it 'expresses a list of values' do
        expect(FixedRange.new([1,2,3]).range_values).to eql [1,2,3]
        expect(FixedRange.new(1..3).range_values).to eql [1,2,3]
      end
    end

    describe SteppedRange do
      it 'expresses an interpolation' do
        expect(SteppedRange.new(1, 3, 3).range_values).to eql [1.0, 2.0, 3.0]
        expect(SteppedRange.new(1, 3, 2).range_values).to eql [1.0, 3.0]
        expect(SteppedRange.new(1, 4, 3).range_values).to eql [1.0, 2.5, 4.0]
      end
    end

    describe FreeVar do
      it 'inspects to a bare string' do
        expect({a: FreeVar.new(:x)}.inspect).to eql '{:a=>x}'
      end
    end
  end
end
