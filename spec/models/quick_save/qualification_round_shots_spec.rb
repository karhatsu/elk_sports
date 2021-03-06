require 'spec_helper'

describe QuickSave::QualificationRoundShots do
  let(:shot_count) { 10 }
  let(:race) { create :race, sport_key: Sport::ILMALUODIKKO }
  let(:series) { create :series, race: race }
  let(:competitor10_shots) { [9,9,9,9,8,8,8,8,7,6] }
  let!(:competitor1) { create :competitor, series: series, number: 1 }
  let!(:competitor10) { create :competitor, series: series, number: 10, shots: competitor10_shots }

  context 'when string format as shots is correct and competitor is found' do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,+99*876510', shot_count)
    end

    it 'saves the shots' do
      result = @qs.save
      expect_success result, competitor1, [10, 9, 9, 11, 8, 7, 6, 5, 1, 0]
    end
  end

  context 'when string format as sum is correct and competitor is found' do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,78', shot_count)
    end

    it 'saves the shots' do
      result = @qs.save
      expect_success result, competitor1, nil, 78
    end
  end

  context 'when string format as shots is correct and shotgun shots are saved' do
    let(:race2) { create :race, sport_key: Sport::METSASTYSHAULIKKO }
    let(:series2) { create :series, race: race2 }
    let!(:competitor2) { create :competitor, series: series2, number: 2 }
    let(:shot_count) { 25 }
    before do
      @qs = QuickSave::QualificationRoundShots.new(race2.id, '2,1111111111000000000011111', shot_count)
    end

    it 'saves the shots' do
      result = @qs.save
      expect_success result, competitor2, [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1]
    end
  end

  context 'when string format as shots total is correct and pienoishirvi shots are saved' do
    let(:race2) { create :race, sport_key: Sport::PIENOISHIRVI }
    let(:series2) { create :series, race: race2 }
    let!(:competitor2) { create :competitor, series: series2, number: 2 }
    let(:shot_count) { 20 }
    before do
      @qs = QuickSave::QualificationRoundShots.new(race2.id, '2,157', 20)
    end

    it 'saves the shooting score input' do
      result = @qs.save
      expect_success result, competitor2, nil, 157
    end
  end

  context 'when invalid shot given' do
    before do
      race.update_attribute :sport_key, Sport::ILMAHIRVI
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,+99*876510', shot_count)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /virheellisen numeron/, competitor1
    end
  end

  context 'when too few shots given' do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,+99887651', shot_count)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  context 'when too many shots given' do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,+9988765222', shot_count)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  describe "unknown competitor" do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, '8,9999999999', shot_count)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /ei löytynyt/
    end
  end

  describe "invalid string format" do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,999999x999', shot_count)
    end

    it 'does not save the given result' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  context 'when invalid sum given' do
    before do
      race.update_attribute :sport_key, Sport::ILMAHIRVI
      @qs = QuickSave::QualificationRoundShots.new(race.id, '1,1010', shot_count)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  context 'when string is nil' do
    before do
      @qs = QuickSave::QualificationRoundShots.new(race.id, nil, shot_count)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  describe "when data already stored" do
    describe 'and ++ not used in the beginning' do
      before do
        @qs = QuickSave::QualificationRoundShots.new(race.id, '10,++++998870', shot_count)
      end

      it 'does not save the given result' do
        result = @qs.save
        expect_failure result, /talletettu/, competitor10, competitor10_shots
      end
    end

    describe 'and ++ used in the beginning' do
      before do
        @qs = QuickSave::QualificationRoundShots.new(race.id, '++10,++++998870', shot_count)
      end

      it 'overrides the existing result' do
        result = @qs.save
        expect_success result, competitor10, [10, 10, 10, 10, 9, 9, 8, 8, 7, 0]
      end
    end
  end

  describe "when sum data already stored" do
    let!(:competitor20) { create :competitor, series: series, number: 20, qualification_round_shooting_score_input: 99 }

    describe 'and ++ not used in the beginning' do
      before do
        @qs = QuickSave::QualificationRoundShots.new(race.id, '20,98', shot_count)
      end

      it 'does not save the given result' do
        result = @qs.save
        expect_failure result, /talletettu/, competitor20, nil, 99
      end
    end

    describe 'and ++ used in the beginning' do
      before do
        @qs = QuickSave::QualificationRoundShots.new(race.id, '++20,98', shot_count)
      end

      it 'overrides the existing result' do
        result = @qs.save
        expect_success result, competitor20, nil, 98
      end
    end
  end

  describe 'when also final shots already saved' do
    before do
      competitor10.update_attribute :shots, [9,9,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8]
      @qs = QuickSave::QualificationRoundShots.new(race.id, '++10,5555555555', shot_count)
    end

    it 'overrides only the qualification shots' do
      result = @qs.save
      expect_success result, competitor10, [5,5,5,5,5,5,5,5,5,5,8,8,8,8,8,8,8,8,8,8]
    end
  end

  def expect_success(result, competitor, shots, shooting_score_input = nil)
#    expect(result).to be_truthy
#    expect(@qs.competitor).to eq(competitor)
    expect(@qs.error).to be_nil
    expect(competitor.reload.shots).to eq shots
    expect(competitor.qualification_round_shooting_score_input).to eq shooting_score_input
  end

  def expect_failure(result, error_regex, competitor = nil, original_shots = nil, original_input_sum = nil)
    expect(result).to be_falsey
    expect(@qs.competitor).to eq(competitor)
    expect(@qs.error).to match(error_regex)
    if competitor
      expect(competitor.reload.shots).to eq(original_shots)
      expect(competitor.qualification_round_shooting_score_input).to eq(original_input_sum)
    end
  end
end
