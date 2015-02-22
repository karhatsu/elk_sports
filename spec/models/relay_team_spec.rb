require 'spec_helper'

describe RelayTeam do
  it "create" do
    FactoryGirl.create(:relay_team)
  end

  describe "associations" do
    it { should belong_to(:relay) }
    it { should have_many(:relay_competitors) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }

    describe "number" do
      it { should validate_numericality_of(:number) }
      it { should_not allow_value(0).for(:number) }
      it { should allow_value(1).for(:number) }
      it { should_not allow_value(1.1).for(:number) }

      describe "uniqueness" do
        before do
          FactoryGirl.create(:relay_team)
        end
        it { should validate_uniqueness_of(:number).scoped_to(:relay_id) }
      end
    end

    describe "no_result_reason" do
      it { should allow_value(nil).for(:no_result_reason) }
      it { should allow_value(RelayTeam::DNS).for(:no_result_reason) }
      it { should allow_value(RelayTeam::DNF).for(:no_result_reason) }
      it { should allow_value(RelayTeam::DQ).for(:no_result_reason) }
      it { should_not allow_value('test').for(:no_result_reason) }
      it "should change empty string to nil" do
        team = FactoryGirl.create(:relay_team, :no_result_reason => '')
        expect(team.no_result_reason).to be_nil
      end
    end
  end

  describe "competitors" do
    before do
      @team = FactoryGirl.create(:relay_team)
      @team.relay_competitors << FactoryGirl.build(:relay_competitor,
        :relay_team => @team, :leg => 3)
      @team.relay_competitors << FactoryGirl.build(:relay_competitor,
        :relay_team => @team, :leg => 1)
      @team.relay_competitors << FactoryGirl.build(:relay_competitor,
        :relay_team => @team, :leg => 2)
      @team.reload
    end

    it "should be ordered by leg number" do
      expect(@team.relay_competitors[0].leg).to eq(1)
      expect(@team.relay_competitors[1].leg).to eq(2)
      expect(@team.relay_competitors[2].leg).to eq(3)
    end
  end

  describe "#time_in_seconds" do
    before do
      @relay = FactoryGirl.create(:relay, :legs_count => 3, :start_time => '12:00')
      @team = FactoryGirl.create(:relay_team, :relay => @relay)
      @c1 = FactoryGirl.create(:relay_competitor, :relay_team => @team, :leg => 1,
        :arrival_time => '00:10:00')
      @c2 = FactoryGirl.create(:relay_competitor, :relay_team => @team, :leg => 2,
        :arrival_time => '00:20:54')
    end

    it "should return nil if no last competitor defined" do
      expect(@team.time_in_seconds).to be_nil
    end

    context "when last competitor defined" do
      before do
        @c3 = FactoryGirl.create(:relay_competitor, :relay_team => @team, :leg => 3,
            :arrival_time => '00:31:15')
      end

      it "should return the arrival time for the last competitor" do
        expect(@team.time_in_seconds).to eq(31 * 60 + 15)
      end
    end

    context "when leg number given" do
      it "should return the arrival time for the given competitor" do
        expect(@team.time_in_seconds(2)).to eq(20 * 60 + 54)
      end
    end
    context "when leg number given and adjustment exists" do
      before do
        @c1.adjustment = -20
        @c1.save!
        @c3 = FactoryGirl.create(:relay_competitor, :relay_team => @team, :leg => 3,
          :arrival_time => '00:31:15', :adjustment => 90)
      end
      it "should return the arrival time for the given competitor + adjustment for current and previous legs" do
        expect(@team.time_in_seconds(2)).to eq(20 * 60 + 54 - 20)
      end
    end
  end

  describe "#estimate_penalties_sum" do
    context "when all competitors have nil for penalties" do
      it "should return nil" do
        team = FactoryGirl.create(:relay_team)
        c1 = mock_model(RelayCompetitor, :estimate_penalties => nil)
        c2 = mock_model(RelayCompetitor, :estimate_penalties => nil)
        allow(team).to receive(:relay_competitors).and_return([c1, c2])
        expect(team.estimate_penalties_sum).to be_nil
      end
    end

    context "when at least one competitor has non-nil penalties" do
      it "should return sum of competitors' estimate penalties so that nil refers to 0 penalties" do
        team = FactoryGirl.create(:relay_team)
        c1 = mock_model(RelayCompetitor, :estimate_penalties => 10)
        c2 = mock_model(RelayCompetitor, :estimate_penalties => 2)
        c3 = mock_model(RelayCompetitor, :estimate_penalties => nil)
        allow(team).to receive(:relay_competitors).and_return([c1, c2, c3])
        expect(team.estimate_penalties_sum).to eq(12)
      end
    end
  end

  describe "#shoot_penalties_sum" do
    context "when all competitors have nil for penalties" do
      it "should return nil" do
        team = FactoryGirl.create(:relay_team)
        c1 = mock_model(RelayCompetitor, :misses => nil)
        c2 = mock_model(RelayCompetitor, :misses => nil)
        allow(team).to receive(:relay_competitors).and_return([c1, c2])
        expect(team.shoot_penalties_sum).to be_nil
      end
    end
    
    context "when at least one competitor has non-nil penalties" do
      it "should return the sum of shoot penalties for the team so that nil refers to 0 penalties" do
        team = FactoryGirl.create(:relay_team)
        c1 = mock_model(RelayCompetitor, :misses => 3)
        c2 = mock_model(RelayCompetitor, :misses => 4)
        c3 = mock_model(RelayCompetitor, :misses => nil)
        allow(team).to receive(:relay_competitors).and_return([c1, c2, c3])
        expect(team.shoot_penalties_sum).to eq(7)
      end
    end
  end

  describe "#competitor" do
    it "should return nil if no competitor defined for given leg" do
      relay_team = FactoryGirl.build(:relay_team)
      expect(relay_team.competitor(2)).to be_nil
    end

    context "when competitor exists for given leg" do
      before do
        @team = FactoryGirl.create(:relay_team)
        @comp3 = FactoryGirl.build(:relay_competitor, :relay_team => @team, :leg => 3)
        @comp1 = FactoryGirl.build(:relay_competitor, :relay_team => @team, :leg => 1)
        @team.relay_competitors << @comp1
        @team.relay_competitors << @comp3
      end

      it "should return the competitor" do
        comp2 = FactoryGirl.build(:relay_competitor, :relay_team => @team, :leg => 2)
        @team.relay_competitors << comp2
        expect(@team.competitor(3)).to eq(@comp3)
      end

      it "should return the competitor even though some other competitor missing" do
        expect(@team.competitor(3)).to eq(@comp3)
      end

      it "should return the competitor also when string instead of int is given" do
        expect(@team.competitor("1")).to eq(@comp1)
      end
    end
  end
end
