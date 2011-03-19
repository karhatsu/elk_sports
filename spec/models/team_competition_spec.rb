require 'spec_helper'

describe TeamCompetition do
  it "create" do
    Factory.create(:team_competition)
  end

  describe "associations" do
    it { should belong_to(:race) }
    it { should have_and_belong_to_many(:series) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }

    describe "team_competitor_count" do
      it { should validate_numericality_of(:team_competitor_count) }
      it { should_not allow_value(nil).for(:team_competitor_count) }
      it { should_not allow_value(0).for(:team_competitor_count) }
      it { should_not allow_value(1).for(:team_competitor_count) }
      it { should allow_value(2).for(:team_competitor_count) }
      it { should_not allow_value(2.1).for(:team_competitor_count) }
    end
  end

  describe "#results_for_competitors" do
    before do
      @tc = Factory.build(:team_competition, :team_competitor_count => 2)
    end

    it "should return empty array if none of the clubs have enough competitors" do
      @club = mock_model(Club)
      @c = mock_model(Competitor, :points => 1100, :club => @club,
        :shot_points => 300, :time_in_seconds => 500, :unofficial => false)
      Competitor.should_receive(:sort).with([@c]).and_return([@c])
      @tc.results_for_competitors([@c]).should == []
    end

    context "when the clubs have enough competitors" do
      before do
        @club_best_total_points = mock_model(Club, :name => 'Club 1')
        @club_best_single_points = mock_model(Club, :name => 'Club 2')
        @club_best_single_shots = mock_model(Club, :name => 'Club 3')
        @club_best_single_time = mock_model(Club, :name => 'Club 4')
        @club_worst = mock_model(Club, :name => 'Club 5')
        @club_small = mock_model(Club, :name => 'Club small')
        @club_unofficial = mock_model(Club, :name => 'Club unofficial')

        @club_best_total_points_c1 = create_competitor(@club_best_total_points, 1100)
        @club_best_total_points_c2 = create_competitor(@club_best_total_points, 1000)
        @club_best_total_points_c_excl = create_competitor(@club_best_total_points, 999)
        @club_best_single_points_c1 = create_competitor(@club_best_single_points, 1050)
        @club_best_single_points_c2 = create_competitor(@club_best_single_points, 800)
        @club_best_single_shots_c1 = create_competitor(@club_best_single_shots, 1049)
        @club_best_single_shots_c2 = create_competitor(@club_best_single_shots, 801,
          :shot_points => 201)
        @club_best_single_time_c1 = create_competitor(@club_best_single_time, 1049)
        @club_best_single_time_c2 = create_competitor(@club_best_single_time, 801,
          :time_in_seconds => 999)
        @club_worst_c1 = create_competitor(@club_worst, 1049)
        @club_worst_c2 = create_competitor(@club_worst, 801)

        @club_small_c = create_competitor(@club_small, 1200)
        @club_small_nil_points = create_competitor(@club_small, nil)
        @club_unofficial1 = create_competitor(@club_unofficial, 1200, :unofficial => true)
        @club_unofficial2 = create_competitor(@club_unofficial, 1200, :unofficial => true)

        competitors =
          [@club_small_c, @club_best_total_points_c1, @club_best_single_points_c1,
            @club_best_single_shots_c1, @club_best_single_time_c1,
            @club_worst_c1,
            @club_best_total_points_c2, @club_best_total_points_c_excl,
            @club_best_single_shots_c2,
            @club_best_single_time_c2, @club_worst_c2,
            @club_best_single_points_c2,
            @club_unofficial1, @club_unofficial2, @club_small_nil_points]
        Competitor.should_receive(:sort).with(competitors).and_return(competitors)
        @results = @tc.results_for_competitors(competitors)
      end

      describe "should return an array of hashes" do
        it "including only the clubs with enough official competitors with complete points " +
            "so that the clubs are ordered: 1. total points " +
            "2. best individual points 3. best individual shot points " +
            "4. fastest individual time" do
          @results.length.should == 5
          @results[0][:club].should == @club_best_total_points
          @results[1][:club].should == @club_best_single_points
          @results[2][:club].should == @club_best_single_shots
          @results[3][:club].should == @club_best_single_time
          @results[4][:club].should == @club_worst
        end

        it "including total points" do
          @results[0][:points].should == 1100 + 1000
          @results[1][:points].should == 1050 + 800
          @results[2][:points].should == 1049 + 801
          @results[3][:points].should == 1049 + 801
          @results[4][:points].should == 1049 + 801
        end

        it "including ordered competitors inside of each team" do
          @results[0][:competitors].length.should == 2
          @results[0][:competitors][0].should == @club_best_total_points_c1
          @results[0][:competitors][1].should == @club_best_total_points_c2
          @results[1][:competitors].length.should == 2
          @results[1][:competitors][0].should == @club_best_single_points_c1
          @results[1][:competitors][1].should == @club_best_single_points_c2
        end
      end

      def create_competitor(club, points, options={})
        mock_model(Competitor, {:points => points, :club => club,
            :shot_points => 200, :time_in_seconds => 1000,
            :unofficial => false}.merge(options))
      end
    end
  end
end
