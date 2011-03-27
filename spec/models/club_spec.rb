require 'spec_helper'

describe Club do
  describe "create" do
    it "should create club with valid attrs" do
      Factory.create(:club)
    end
  end

  describe "validation" do
    it { should validate_presence_of(:name) }

    describe "unique name" do
      before do
        Factory.create(:club)
      end
      it { should validate_uniqueness_of(:name).scoped_to(:race_id) }
    end
  end

  describe "associations" do
    it { should belong_to(:race) }
    it { should have_many(:competitors) }
  end

  describe "removal" do
    it "should be allowed when no competitors" do
      club = Factory.create(:club)
      club.destroy
      club.should be_destroyed
    end

    it "should not be allowed when club has competitors" do
      club = Factory.create(:club)
      club.competitors << Factory.build(:competitor)
      club.should have(1).competitors
      club.destroy
      club.should_not be_destroyed
    end
  end

  describe "#result_name" do
    it "should return long name when long name set" do
      club = Factory.create(:club, :name => 'PS', :long_name => 'Pohjois-Savo')
      club.expanded.should == 'Pohjois-Savo'
    end

    it "should return name when long name not set" do
      club = Factory.create(:club, :name => 'PS')
      club.expanded.should == 'PS'
    end
  end
end
