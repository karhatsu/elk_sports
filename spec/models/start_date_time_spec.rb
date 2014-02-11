require 'spec_helper'

describe StartDateTime do
  RSpec.configure do |c|
    c.include StartDateTime
  end

  describe "#start_datetime" do
    it "should return nil when no start time" do
      start_date_time(mock_model(Race), 1, nil).should be_nil
    end

    it "should return nil when no race" do
      start_date_time(nil, 1, '13:45:31').should be_nil
    end

    it "should return nil when no race start date" do
      race = FactoryGirl.build(:race, :start_date => nil)
      start_date_time(race, 1, '13:45:31').should be_nil
    end

    context "when race date and start time available" do
      before do
        @race = FactoryGirl.build(:race, :start_date => '2011-06-30', :start_time => '10:00')
        series = FactoryGirl.build(:series, :race => @race, :start_time => '03:45:31')
        @start_time = series.start_time
        @original_zone = Time.zone
      end

      it "should return the combination of race date and time and series start time when both available" do
        start_date_time(@race, 1, @start_time).strftime('%d.%m.%Y %H:%M:%S').should == '30.06.2011 13:45:31'
      end

      it "should return the object with local zone" do
        Time.zone = 'Hawaii'
        start_date_time(@race, 1, @start_time).zone.should == 'HST'
      end

      it "should return the correct date when series start day is not 1" do
        @race.end_date = '2011-07-02'
        start_date_time(@race, 3, @start_time).strftime('%d.%m.%Y %H:%M:%S').should == '02.07.2011 13:45:31'
      end

      after do
        Time.zone = @original_zone
      end
    end
  end
end