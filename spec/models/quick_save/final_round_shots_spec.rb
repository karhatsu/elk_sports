require 'spec_helper'

describe QuickSave::FinalRoundShots do
  let(:race) { create :race, sport_key: Sport::ILMALUODIKKO }
  let(:series) { create :series, race: race }
  let(:competitor10_shots) { [9,9,9,9,8,8,8,8,7,6] }
  let!(:competitor1) { create :competitor, series: series, number: 1 }
  let!(:competitor10) { create :competitor, series: series, number: 10, shots: competitor10_shots }

  context 'when string format is correct and competitor with qualification round shots is found' do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, '10,+99*876510')
    end

    it 'saves the shots after the existing qualification round shots' do
      result = @qs.save
      expect_success result, competitor10, competitor10_shots + [10, 9, 9, 11, 8, 7, 6, 5, 1, 0]
    end
  end

  context 'when no shots yet' do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, '1,+99*876510')
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /Alkukilpailun laukaukset puuttuvat/, competitor1
    end
  end

  context 'when not all qualification round shots yet' do
    let(:nine_shots) { [1, 2, 3, 4, 5, 6, 7, 8, 9] }
    before do
      competitor1.update_attribute :shots, nine_shots
      @qs = QuickSave::FinalRoundShots.new(race.id, '1,+99*876510')
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /Alkukilpailun laukaukset puuttuvat/, competitor1, nine_shots
    end
  end

  context 'when invalid shot given' do
    before do
      race.update_attribute :sport_key, Sport::ILMAHIRVI
      @qs = QuickSave::FinalRoundShots.new(race.id, '10,+99*876510')
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /virheellisen numeron/, competitor10, competitor10_shots
    end
  end

  context 'when too few shots given' do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, '10,+99887651')
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  context 'when too many shots given' do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, '10,+9988765222')
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  describe "unknown competitor" do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, '8,9999999999')
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /ei löytynyt/
    end
  end

  describe "invalid string format" do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, '10,999999x999')
    end

    it 'does not save the given result' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  context 'when string is nil' do
    before do
      @qs = QuickSave::FinalRoundShots.new(race.id, nil)
    end

    it 'does not save anything' do
      result = @qs.save
      expect_failure result, /muoto/
    end
  end

  describe "when final shots already stored" do
    let(:with_final_shots) { [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 7, 7, 7, 7, 7, 5, 5, 5, 5, 5] }

    before do
      competitor10.update_attribute :shots, with_final_shots
    end

    describe 'and ++ not used in the beginning' do
      before do
        @qs = QuickSave::FinalRoundShots.new(race.id, '10,++++998870')
      end

      it 'does not save the given shots' do
        result = @qs.save
        expect_failure result, /talletettu/, competitor10, with_final_shots
      end
    end

    describe 'and ++ used in the beginning' do
      before do
        @qs = QuickSave::FinalRoundShots.new(race.id, '++10,++++998870')
      end

      it 'overrides the existing final shots' do
        result = @qs.save
        expect_success result, competitor10, [9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 9, 9, 8, 8, 7, 0]
      end
    end
  end

  def expect_success(result, competitor, shots)
    expect(result).to be_truthy
    expect(@qs.competitor).to eq(competitor)
    expect(@qs.error).to be_nil
    expect(competitor.reload.shots).to eq shots
  end

  def expect_failure(result, error_regex, competitor = nil, original_shots = nil)
    expect(result).to be_falsey
    expect(@qs.competitor).to eq(competitor)
    expect(@qs.error).to match(error_regex)
    if competitor
      expect(competitor.reload.shots).to eq(original_shots)
    end
  end
end
