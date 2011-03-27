require 'spec_helper'

describe ApplicationHelper do
  describe "#points_print" do
    it "should print no result reason if it is defined" do
      competitor = mock_model(Competitor, :no_result_reason => Competitor::DNS,
        :points => 145)
      helper.points_print(competitor).should ==
        "<span class='explanation' title='Kilpailija ei osallistunut kilpailuun'>DNS</span>"
    end

    it "should print points in case they are available" do
      competitor = mock_model(Competitor, :no_result_reason => nil,
        :points => 145, :series => nil)
      helper.points_print(competitor).should == "145"
    end

    it "should print points in brackets if only partial points are available" do
      competitor = mock_model(Competitor, :no_result_reason => nil,
        :points => nil, :points! => 100)
      helper.points_print(competitor).should == "(100)"
    end

    it "should print - if no points at all" do
      competitor = mock_model(Competitor, :no_result_reason => nil,
        :points => nil, :points! => nil, :series => nil)
      helper.points_print(competitor).should == "-"
    end
  end

  describe "#datetime_print" do
    before do
      @time = Time.local(2010, 5, 8, 9, 8, 1)
    end

    it "should print empty string if nil given" do
      helper.datetime_print(nil).should == ''
    end

    it "should print d.m.Y as default format" do
      helper.datetime_print(@time).should == '08.05.2010'
    end

    it "should include hours and minutes if asked" do
      helper.datetime_print(@time, true).should == '08.05.2010 09:08'
    end

    it "should include hours, minutes and seconds if asked" do
      helper.datetime_print(@time, true, true).should == '08.05.2010 09:08:01'
    end

    it "should not print seconds if H/M not wanted and seconds wanted" do
      helper.datetime_print(@time, false, true).should == '08.05.2010'
    end

    it "should print given string instead of empty string if defined and nil" do
      helper.datetime_print(nil, true, false, 'none').should == 'none'
    end
  end

  describe "#series_datetime_print" do
    before do
      @race = mock_model(Race, :start_date => '2010-12-25')
      start_time = Time.local(2000, 1, 1, 12, 30, 0)
      @series = mock_model(Series, :race => @race, :start_day => 3, :start_time => start_time)
    end

    it "should call datetime_print with correct date and time" do
      datetime = DateTime.parse('2010-12-27 12:30')
      helper.should_receive(:datetime_print).with(datetime, false, false, '').
        and_return('result')
      helper.series_datetime_print(@series).should == 'result'
    end
  end

  describe "#date_print" do
    it "should return DD.MM.YYYY" do
      time = Time.local(2010, 5, 8, 9, 8, 1)
      helper.date_print(time).should == '08.05.2010'
    end
  end

  describe "#time_print" do
    before do
      @time = Time.local(2010, 5, 8, 9, 8, 1)
    end

    it "should print empty string if nil given" do
      helper.time_print(nil).should == ''
    end

    it "should print HH:MM as default format" do
      helper.time_print(@time).should == '09:08'
    end

    it "should include seconds if asked" do
      helper.time_print(@time, true).should == '09:08:01'
    end

    it "should print given string instead of empty string if defined and nil" do
      helper.time_print(nil, true, 'none').should == 'none'
    end

    it "should print given string as raw instead of empty string if defined and nil" do
      helper.time_print(nil, true, '&nbsp;').should == '&nbsp;'
    end
  end

  describe "#time_from_seconds" do
    it "should return dash when nil given" do
      helper.time_from_seconds(nil).should == "-"
    end

    it "should return seconds when less than 60" do
      helper.time_from_seconds(59).should == "00:59"
    end

    it "should return minutes and seconds when more than 60" do
      helper.time_from_seconds(60).should == "01:00"
      helper.time_from_seconds(61).should == "01:01"
      helper.time_from_seconds(131).should == "02:11"
    end

    it "should return hours, minutes and seconds when at least 1 hour" do
      helper.time_from_seconds(3600).should == "1:00:00"
      helper.time_from_seconds(3601).should == "1:00:01"
    end

    it "should convert decimal seconds to integer" do
      helper.time_from_seconds(60.0).should == "01:00"
      helper.time_from_seconds(61.1).should == "01:01"
      helper.time_from_seconds(131.2).should == "02:11"
      helper.time_from_seconds(3601.6).should == "1:00:01"
    end

    it "should return negative hours, minutes and seconds when at least 1 hour" do
      helper.time_from_seconds(-3600).should == "-1:00:00"
      helper.time_from_seconds(-3601).should == "-1:00:01"
    end
    it "should return hours, minutes and seconds with minus or plus sign when alwayssigned" do
      helper.time_from_seconds(3600, true).should == "+1:00:00"
      helper.time_from_seconds(3601, true).should == "+1:00:01"
      helper.time_from_seconds(-3601, true).should == "-1:00:01"
    end
  end

  describe "#relay_time_adjustment" do
    before do
      helper.stub!(:time_from_seconds).and_return('00:01')
    end

    it "should return nothing when nil given" do
      helper.relay_time_adjustment(nil).should == ""
    end

    it "should return nothing when 0 seconds given" do
      helper.relay_time_adjustment(0).should == ""
    end

    it "should return the html span block when 1 second given" do
      helper.relay_time_adjustment(1).should == "(<span class='adjustment' title=\"Aika sisältää korjausta 00:01\">00:01</span>)"
    end
  end

  describe "#shot_points_and_total" do
    it "should print empty string if no result reason defined" do
      competitor = mock_model(Competitor, :shots_sum => 88,
        :no_result_reason => Competitor::DNS)
      helper.shot_points_and_total(competitor).should == ''
    end

    it "should return dash when no shots sum" do
      competitor = mock_model(Competitor, :shots_sum => nil,
        :no_result_reason => nil)
      helper.shot_points_and_total(competitor).should == "-"
    end

    it "should return shot points and sum in brackets" do
      competitor = mock_model(Competitor, :shot_points => 480, :shots_sum => 80,
        :no_result_reason => nil)
      helper.shot_points_and_total(competitor).should == "480 (80)"
    end
  end

  describe "#shots_list" do
    it "should return dash when no shots sum" do
      competitor = mock_model(Competitor, :shots_sum => nil)
      helper.shots_list(competitor).should == "-"
    end

    it "should return input total if such is given" do
      competitor = mock_model(Competitor, :shots_sum => 45, :shots_total_input => 45)
      helper.shots_list(competitor).should == 45
    end

    it "should return comma separated list if individual shots defined" do
      shots = [10, 1, 9, 5, 5, nil, nil, 6, 4, 0]
      competitor = mock_model(Competitor, :shots_sum => 50,
        :shots_total_input => nil, :shot_values => shots)
      helper.shots_list(competitor).should == "10,1,9,5,5,0,0,6,4,0"
    end
  end

  describe "#print_estimate_diff" do
    it "should return empty string when nil given" do
      helper.print_estimate_diff(nil).should == "-"
    end

    it "should return negative diff with minus sign" do
      helper.print_estimate_diff(-12).should == "-12"
    end

    it "should return positive diff with plus sign" do
      helper.print_estimate_diff(13).should == "+13"
    end
  end

  describe "#estimate_diffs" do
    describe "2 estimates" do
      before do
        @series = mock_model(Series, :estimates => 2)
      end

      it "should return empty string when no estimates" do
        competitor = mock_model(Competitor, :estimate1 => nil, :estimate2 => nil,
          :series => @series)
        helper.estimate_diffs(competitor).should == ""
      end

      it "should return first and dash when first is available" do
        competitor = mock_model(Competitor, :estimate1 => 50, :estimate2 => nil,
          :estimate_diff1_m => 10, :estimate_diff2_m => nil, :series => @series)
        helper.estimate_diffs(competitor).should == "+10m/-"
      end

      it "should return dash and second when second is available" do
        competitor = mock_model(Competitor, :estimate1 => nil, :estimate2 => 60,
          :estimate_diff1_m => nil, :estimate_diff2_m => -5, :series => @series)
        helper.estimate_diffs(competitor).should == "-/-5m"
      end

      it "should return both when both are available" do
        competitor = mock_model(Competitor, :estimate1 => 120, :estimate2 => 60,
          :estimate_diff1_m => -5, :estimate_diff2_m => 14, :series => @series)
        helper.estimate_diffs(competitor).should == "-5m/+14m"
      end
    end

    describe "4 estimates" do
      before do
        @series = mock_model(Series, :estimates => 4)
      end

      it "should return empty string when no estimates" do
        competitor = mock_model(Competitor, :estimate1 => nil, :estimate2 => nil,
          :estimate3 => nil, :estimate4 => nil, :series => @series)
        helper.estimate_diffs(competitor).should == ""
      end

      it "should return dash for others when only third is available" do
        competitor = mock_model(Competitor, :estimate1 => 50, :estimate2 => nil,
          :estimate_diff1_m => nil, :estimate_diff2_m => nil,
          :estimate_diff3_m => 12, :estimate_diff4_m => nil, :series => @series)
        helper.estimate_diffs(competitor).should == "-/-/+12m/-"
      end

      it "should return dash for others when only fourth is available" do
        competitor = mock_model(Competitor, :estimate1 => 50, :estimate2 => nil,
          :estimate_diff1_m => nil, :estimate_diff2_m => nil,
          :estimate_diff3_m => nil, :estimate_diff4_m => -5, :series => @series)
        helper.estimate_diffs(competitor).should == "-/-/-/-5m"
      end

      it "should return dash for third when others are available" do
        competitor = mock_model(Competitor, :estimate1 => 50, :estimate2 => nil,
          :estimate_diff1_m => 10, :estimate_diff2_m => -9,
          :estimate_diff3_m => nil, :estimate_diff4_m => 12, :series => @series)
        helper.estimate_diffs(competitor).should == "+10m/-9m/-/+12m"
      end

      it "should return dash for fourth when others are available" do
        competitor = mock_model(Competitor, :estimate1 => nil, :estimate2 => 60,
          :estimate_diff1_m => 10, :estimate_diff2_m => -5,
          :estimate_diff3_m => 12, :estimate_diff4_m => nil, :series => @series)
        helper.estimate_diffs(competitor).should == "+10m/-5m/+12m/-"
      end

      it "should return all diffs when all are available" do
        competitor = mock_model(Competitor, :estimate1 => 120, :estimate2 => 60,
          :estimate_diff1_m => -5, :estimate_diff2_m => 14,
          :estimate_diff3_m => 12, :estimate_diff4_m => -1, :series => @series)
        helper.estimate_diffs(competitor).should == "-5m/+14m/+12m/-1m"
      end
    end
  end

  describe "#estimate_points" do
    it "should print empty string if no result reason defined" do
      competitor = mock_model(Competitor, :shots_sum => 88,
        :no_result_reason => Competitor::DNS)
      helper.estimate_points(competitor).should == ''
    end

    it "should return dash if no estimate points" do
      competitor = mock_model(Competitor, :estimate_points => nil,
        :no_result_reason => nil)
      helper.estimate_points(competitor).should == "-"
    end

    it "should return points otherwise" do
      competitor = mock_model(Competitor, :estimate_points => 189,
        :no_result_reason => nil)
      helper.estimate_points(competitor).should == 189
    end
  end

  describe "#estimate_points_and_diffs" do
    it "should print empty string if no result reason defined" do
      competitor = mock_model(Competitor, :shots_sum => 88,
        :no_result_reason => Competitor::DNS)
      helper.estimate_points_and_diffs(competitor).should == ''
    end

    it "should return dash if no estimate points" do
      competitor = mock_model(Competitor, :estimate_points => nil,
        :no_result_reason => nil)
      helper.estimate_points_and_diffs(competitor).should == "-"
    end

    it "should return points and diffs when points available" do
      competitor = mock_model(Competitor, :estimate_points => 189,
        :no_result_reason => nil)
      helper.should_receive(:estimate_diffs).with(competitor).and_return("3m")
      helper.estimate_points_and_diffs(competitor).should == "189 (3m)"
    end
  end

  describe "#correct_estimate" do
    it "should raise error when index less than 1" do
      lambda { helper.correct_estimate(nil, 0, '') }.should raise_error
    end

    it "should raise error when index more than 4" do
      lambda { helper.correct_estimate(nil, 5, '') }.should raise_error
    end

    context "race not finished" do
      before do
        race = mock_model(Race, :finished => false)
        series = mock_model(Series, :race => race)
        @competitor = mock_model(Competitor, :series => series,
          :correct_estimate1 => 100, :correct_estimate2 => 150)
      end

      specify { helper.correct_estimate(@competitor, 1, '-').should == '-' }
      specify { helper.correct_estimate(@competitor, 2, '-').should == '-' }
      specify { helper.correct_estimate(@competitor, 3, '-').should == '-' }
      specify { helper.correct_estimate(@competitor, 4, '-').should == '-' }
    end

    context "race finished" do
      context "estimates available" do
        before do
          race = mock_model(Race, :finished => true)
          series = mock_model(Series, :race => race)
          @competitor = mock_model(Competitor, :series => series,
            :correct_estimate1 => 100, :correct_estimate2 => 150,
            :correct_estimate3 => 110, :correct_estimate4 => 160)
        end

        specify { helper.correct_estimate(@competitor, 1, '-').should == 100 }
        specify { helper.correct_estimate(@competitor, 2, '-').should == 150 }
        specify { helper.correct_estimate(@competitor, 3, '-').should == 110 }
        specify { helper.correct_estimate(@competitor, 4, '-').should == 160 }
      end

      context "estimates not available" do
        before do
          race = mock_model(Race, :finished => true)
          series = mock_model(Series, :race => race)
          @competitor = mock_model(Competitor, :series => series,
            :correct_estimate1 => nil, :correct_estimate2 => nil,
            :correct_estimate3 => nil, :correct_estimate4 => nil)
        end

        specify { helper.correct_estimate(@competitor, 1, '-').should == '-' }
        specify { helper.correct_estimate(@competitor, 2, '-').should == '-' }
        specify { helper.correct_estimate(@competitor, 3, '-').should == '-' }
        specify { helper.correct_estimate(@competitor, 4, '-').should == '-' }
      end
    end
  end

  describe "#time_points_and_time" do
    it "should print empty string if no result reason defined" do
      competitor = mock_model(Competitor, :shots_sum => 88,
        :no_result_reason => Competitor::DNS)
      helper.time_points_and_time(competitor).should == ''
    end

    it "should return dash when no time" do
      competitor = mock_model(Competitor, :time_in_seconds => nil,
        :no_result_reason => nil)
      helper.time_points_and_time(competitor).should == "-"
    end

    it "should return time points and time in brackets" do
      competitor = mock_model(Competitor, :time_points => 270,
        :time_in_seconds => 2680, :no_result_reason => nil)
      helper.should_receive(:time_from_seconds).with(2680).and_return("45:23")
      helper.time_points_and_time(competitor).should == "270 (45:23)"
    end

    it "should wrap with best time span when full points" do
      competitor = mock_model(Competitor, :time_points => 300,
        :time_in_seconds => 2680, :no_result_reason => nil)
      helper.should_receive(:time_from_seconds).with(2680).and_return("45:23")
      helper.time_points_and_time(competitor).
        should == "<span class='series_best_time'>300 (45:23)</span>"
    end
  end

  describe "#full_name" do
    specify { helper.full_name(mock_model(Competitor, :last_name => "Tester",
        :first_name => "Tim")).should == "Tester Tim" }

    describe "first name first" do
      specify { helper.full_name(mock_model(Competitor, :last_name => "Tester",
          :first_name => "Tim"), true).should == "Tim Tester" }
    end
  end

  describe "#date_interval" do
    it "should print start - end when dates differ" do
      helper.date_interval("2010-08-01".to_date, "2010-08-03".to_date).
        should == "01.08.2010 - 03.08.2010"
    end

    it "should print only start date when end date is same" do
      helper.date_interval("2010-08-03".to_date, "2010-08-03".to_date).
        should == "03.08.2010"
    end

    it "should print only start date when end date is nil" do
      helper.date_interval("2010-08-03".to_date, nil).should == "03.08.2010"
    end
  end

  describe "#race_date_interval" do
    it "should call date_interval with race dates" do
      race = Factory.build(:race)
      helper.should_receive(:date_interval).with(race.start_date, race.end_date).
        and_return('result')
      helper.race_date_interval(race).should == 'result'
    end
  end

  describe "#yes_or_empty" do
    context "when boolean is true" do
      it "should return yes icon" do
        helper.yes_or_empty('test').should match(/<img .* src=.*icon_yes.gif.*\/>/)
      end
    end

    context "when boolean is false" do
      it "should return html space when no block given" do
        helper.yes_or_empty(nil).should == '&nbsp;'
      end

      it "should call block when block given" do
        s = mock(Series)
        s.should_receive(:id)
        helper.yes_or_empty(false) do s.id end
      end
    end
  end

  describe "#value_or_space" do
    it "should return value when value is available" do
      helper.value_or_space('test').should == 'test'
    end

    it "should return html space when value not available" do
      helper.value_or_space(nil).should == '&nbsp;'
      helper.value_or_space(false).should == '&nbsp;'
    end
  end

  describe "#start_days_form_field" do
    before do
      @f = mock(String)
      @race = mock_model(Race, :start_date => '2010-12-20')
      @series = mock_model(Series, :race => @race)
    end

    context "when only one start day" do
      it "should return hidden field with value 1" do
        @series.should_receive(:start_day=).with(1)
        @f.should_receive(:hidden_field).with(:start_day).and_return("input")
        @race.stub!(:days_count).and_return(1)
        helper.start_days_form_field(@f, @series).should == "input"
      end
    end

    context "when more than one day" do
      it "should return dropdown menu with different dates" do
        @series.should_receive(:start_day).and_return(2)
        options = options_for_select([['20.12.2010', 1], ['21.12.2010', 2]], 2)
        @f.should_receive(:select).with(:start_day, options).and_return("select")
        @race.stub!(:days_count).and_return(2)
        helper.start_days_form_field(@f, @series).should == "select"
      end
    end
  end

  describe "#offline?" do
    it "should return true when Mode.offline? returns true" do
      Mode.stub!(:offline?).and_return(true)
      helper.should be_offline
    end

    it "should return true when Mode.offline? returns false" do
      Mode.stub!(:offline?).and_return(false)
      helper.should_not be_offline
    end
  end

  describe "#link_with_protocol" do
    it "should return the given link if it starts with http://" do
      helper.link_with_protocol('http://www.test.com').should == 'http://www.test.com'
    end

    it "should return the given link if it starts with https://" do
      helper.link_with_protocol('https://www.test.com').should == 'https://www.test.com'
    end

    it "should return http protocol + the given link if the protocol is missing" do
      helper.link_with_protocol('www.test.com').should == 'http://www.test.com'
    end
  end

  describe "#next_result_rotation" do
    context "when url list is empty" do
      context "and parameter is non-nil" do
        it "should return the parameter url" do
          stub!(:result_rotation_list).and_return([])
          next_result_rotation('/abc').should == '/abc'
        end
      end

      context "and parameter is nil" do
        before do
          path = '/this/is/race/frontpage'
          stub!(:race_path).and_return(path)
        end

        it "should return the race front page" do
          stub!(:result_rotation_list).and_return([])
          next_result_rotation(nil).should == race_path()
        end
      end
    end
    
    context "when url list is not empty" do
      before do
        stub!(:result_rotation_list).and_return(['/races/12/relays/1', '/series/56/competitors', '/series/67/competitors'])
      end

      context "when nil url is given" do
        it "should return first url from url rotation" do
          next_result_rotation(nil).should == result_rotation_list[0]
        end
      end

      context "when unknown url is given" do
        it "should return first url from url rotation" do
          next_result_rotation('/unknown').should == result_rotation_list[0]
        end
      end

      context "when existing url is given" do
        it "should return next url from url rotation" do
          next_result_rotation(result_rotation_list[0]).should == result_rotation_list[1]
        end
      end

      context "when another existing url is given" do
        it "should return next url from url rotation" do
          next_result_rotation(result_rotation_list[1]).should == result_rotation_list[2]
        end
      end

      context "when last url is given" do
        it "should return first url from url rotation" do
          next_result_rotation(result_rotation_list.size - 1).should == result_rotation_list[0]
        end
      end
    end
  end

  describe "#result_rotation_list" do
    it "should return an empty list when race in the future" do
      race = Factory.create(:race, :start_date => Date.today - 1)
      race.series << build_series(race, 1)
      race.relays << build_relay(race, 1)
      result_rotation_list(race).size.should == 0
    end

    it "should return an empty list when race was in the past" do
      race = Factory.create(:race, :start_date => Date.today - 2,
        :end_date => Date.today - 1)
      race.series << build_series(race, 1)
      race.relays << build_relay(race, 1)
      result_rotation_list(race).size.should == 0
    end

    context "when race is ongoing today" do
      before do
        @race = Factory.create(:race, :start_date => Date.today,
          :end_date => Date.today + 1)

        @series1_1 = build_series(@race, 1)
        @series1_2 = build_series(@race, 1)
        @series2 = build_series(@race, 2)
        @race.series << @series1_1
        @race.series << @series1_2
        @race.series << @series2

        @tc1 = build_team_competition(@race)
        @tc2 = build_team_competition(@race)
        @race.team_competitions << @tc1
        @race.team_competitions << @tc2

        @relay1_1 = build_relay(@race, 1)
        @relay1_2 = build_relay(@race, 1)
        @relay2 = build_relay(@race, 2)
        @race.relays << @relay1_1
        @race.relays << @relay1_2
        @race.relays << @relay2
      end

      context "when race has started today" do
        it "should return the paths for series today, team competitions and relays today" do
          list = result_rotation_list(@race)
          list.size.should == 6
          list[0].should == series_competitors_path(@series1_1)
          list[1].should == series_competitors_path(@series1_2)
          list[2].should == race_team_competition_path(@race, @tc1)
          list[3].should == race_team_competition_path(@race, @tc2)
          list[4].should == race_relay_path(@race, @relay1_1)
          list[5].should == race_relay_path(@race, @relay1_2)
        end
      end

      context "when race started yesterday" do
        it "should return the paths for series today, team competitions and relays today" do
          @race.start_date = Date.today - 1
          @race.end_date = Date.today
          @race.save!
          list = result_rotation_list(@race)
          list.size.should == 4
          list[0].should == series_competitors_path(@series2)
          list[1].should == race_team_competition_path(@race, @tc1)
          list[2].should == race_team_competition_path(@race, @tc2)
          list[3].should == race_relay_path(@race, @relay2)
        end
      end

      context "when no series for today" do
        it "should not return team competitions" do
          @series1_1.destroy
          @series1_2.destroy
          @race.reload
          list = result_rotation_list(@race)
          list.size.should == 2
          list[0].should == race_relay_path(@race, @relay1_1)
          list[1].should == race_relay_path(@race, @relay1_2)
        end
      end
    end

    def build_series(race, start_day)
      Factory.build(:series, :race => race, :start_day => start_day)
    end

    def build_team_competition(race)
      Factory.build(:team_competition, :race => race)
    end

    def build_relay(race, start_day)
      Factory.build(:relay, :race => race, :start_day => start_day)
    end
  end

  describe "#result_refresh_interval" do
    before do
      stub!(:result_rotation_cookie).and_return('3')
    end
    context "when development environment" do
      before do
        Rails.stub!(:env).and_return('development')
      end
      it "should return the given refresh rate" do
        result_refresh_interval(2).should == 2
      end
    end
    context "when not development environment" do
      before do
        Rails.stub!(:env).and_return('production')
      end
      it "should return 15 if given refresh rate is less than that" do
        result_refresh_interval(2).should == 15
        end
      it "should return given refresh rate if it is more than 15" do
        result_refresh_interval(30).should == 30
      end
    end
  end

  describe "#refresh_tag" do
    context "when no seriescount cookie set" do
      before do
        stub!(:result_rotation_cookie).and_return(false)
        stub!(:result_refresh_interval).and_return(15)
        helper.stub!(:next_result_rotation).and_return('/abc')
        request_stub = 'request'
        helper.stub!(:request).and_return(request_stub)
        request_stub.stub!(:fullpath).and_return('/xyz')
      end
      it "should return a valid http refresh tag for same page" do
        refresh_tag.should == "<meta http-equiv=\"Refresh\" content=\"15\"/>"
      end
    end

    context "when seriescount cookie set to 3" do
      before do
        stub!(:result_rotation_cookie).and_return('3')
        stub!(:result_refresh_interval).and_return(15)
        helper.stub!(:next_result_rotation).and_return('/abc')
        request_stub = 'request'
        helper.stub!(:request).and_return(request_stub)
        request_stub.stub!(:fullpath).and_return('/xyz')
      end
      it "should return a valid http refresh tag for next page in rotation" do
        refresh_tag.should == "<meta http-equiv=\"Refresh\" content=\"15;/abc\"/>"
      end
    end
  end
  describe "#series_result_title" do
    context "when race is finished" do
      it "should return 'Tulokset'" do
        race = mock_model(Race, :finished? => true)
        series = mock_model(Series, :race => race)
        series_result_title(series).should == 'Tulokset'
      end
    end

    context "when race is not finished" do
      before do
        race = mock_model(Race, :finished? => false)
        @series = mock_model(Series, :race => race)
        @competitors = mock(Array)
        @series.should_receive(:competitors).and_return(@competitors)
      end

      context "and no competitors" do
        it "should return 'Välikaikatulokset (päivitetty: -)'" do
          @competitors.should_receive(:maximum).with(:updated_at).and_return(nil)
          series_result_title(@series).should == 'Väliaikatulokset (päivitetty: -)'
        end
      end

      context "and has competitors" do
        it "should return 'Väliaikatulokset (päivitetty: <time>)'" do
          time = Time.now
          @competitors.should_receive(:maximum).with(:updated_at).and_return(time)
          should_receive(:datetime_print).with(time, true, true, '-', 'Helsinki').and_return('123')
          series_result_title(@series).should == 'Väliaikatulokset (päivitetty: 123)'
        end
      end
    end
  end

  describe "#correct_estimate_range" do
    it "should return min_number- if no max_number" do
      ce = Factory.build(:correct_estimate, :min_number => 56, :max_number => nil)
      helper.correct_estimate_range(ce).should == "56-"
    end

    it "should return min_number if max_number equals to it" do
      ce = Factory.build(:correct_estimate, :min_number => 57, :max_number => 57)
      helper.correct_estimate_range(ce).should == 57
    end

    it "should return min_number-max_number if both defined and different" do
      ce = Factory.build(:correct_estimate, :min_number => 57, :max_number => 58)
      helper.correct_estimate_range(ce).should == "57-58"
    end
  end
end
