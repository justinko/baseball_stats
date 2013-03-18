require 'test_helper'

describe BaseballStats::Stats::MostImprovedBattingAverage do
  describe '#data' do
    it 'returns the correct data' do
      factory :players, {id: '1', first_name: 'John', last_name: 'Doe'}
      factory :players, {id: '2', first_name: 'Bob', last_name: 'Smith'}

      factory :statistics, {player_id: '1', year: 2011, hits: 36, at_bats: 201}
      factory :statistics, {player_id: '1', year: 2012, hits: 55, at_bats: 220}

      factory :statistics, {player_id: '2', year: 2011, hits: 15, at_bats: 225}
      factory :statistics, {player_id: '2', year: 2012, hits: 25, at_bats: 302}

      data = BaseballStats::Stats::MostImprovedBattingAverage.new(from: 2011, to: 2012).data
      data.count.must_equal 1
      # Would create a custom matcher for the next 2 lines
      data.first.grep(/John Doe \(1\)/).wont_be_empty
      data.first.grep(/BA DIFF: 0.0709/).wont_be_empty
    end
  end
end
