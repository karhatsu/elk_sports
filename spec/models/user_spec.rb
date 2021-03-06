require 'spec_helper'

describe User do
  it "should create user with valid attrs" do
    create(:user)
  end

  describe "validation" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:club_name) }

    describe 'simple bot prevention' do
      context 'when first and last names equal' do
        it 'is not valid' do
          expect(build_with_names('Name', 'Name', 'Club name')).to have(1).errors_on(:base)
        end
      end

      context 'when first name and club name equal' do
        it 'is not valid' do
          expect(build_with_names('Name', 'Last name', 'Name')).to have(1).errors_on(:base)
        end
      end

      context 'when last name and club name equal' do
        it 'is not valid' do
          expect(build_with_names('First name', 'Name', 'Name')).to have(1).errors_on(:base)
        end
      end

      def build_with_names(first_name, last_name, club_name)
        build :user, first_name: first_name, last_name: last_name, club_name: club_name
      end
    end
  end
  
  describe "associations" do
    it { is_expected.to have_and_belong_to_many(:roles) }
    it { is_expected.to have_many(:race_rights) }
    it { is_expected.to have_many(:races).through(:race_rights) }
    it { is_expected.to have_and_belong_to_many(:cups) }
  end

  describe "rights" do
    context "default" do
      it "user should not be admin" do
        expect(build(:user)).not_to be_admin
      end

      it "user should not be official" do
        expect(build(:user)).not_to be_official
      end
    end

    describe "add admin rights" do
      it "should give admin rights for the user" do
        create(:role, :name => Role::ADMIN) unless Role.find_by_name(Role::ADMIN)
        user = build(:user)
        user.add_admin_rights
        expect(user).to be_admin
      end
    end

    describe "add official rights" do
      it "should give official rights for the user" do
        create(:role, :name => Role::OFFICIAL) unless Role.find_by_name(Role::OFFICIAL)
        user = build(:user)
        user.add_official_rights
        expect(user).to be_official
      end
    end
  end
  
  describe "#official_for_race?" do
    before do
      @race = create(:race)
      @user = create(:user)
    end

    it "should return false when no races for this user" do
      expect(@user).not_to be_official_for_race(@race)
    end

    it "should return false when user is not official for the given race" do
      race = create(:race)
      @user.race_rights << RaceRight.new(:user_id => @user.id, :race_id => race.id)
      @user.reload
      expect(@user).not_to be_official_for_race(@race)
    end

    it "should return true when user is official for the given race" do
      @user.race_rights << RaceRight.new(:user_id => @user.id, :race_id => @race.id)
      @user.reload
      expect(@user).to be_official_for_race(@race)
    end
  end
  
  describe "#official_for_cup?" do
    before do
      @cup = create(:cup)
      @user = build(:user)
    end
    
    it "should return false when no cups for this user" do
      expect(@user).not_to be_official_for_cup(@cup)
    end

    it "should return false when user is not official for the given cup" do
      cup = create(:cup)
      @user.cups << cup
      expect(@user).not_to be_official_for_cup(@cup)
    end

    it "should return true when user is official for the given cup" do
      @user.cups << @cup
      expect(@user).to be_official_for_cup(@cup)
    end
  end
  
  describe "#has_full_rights_for_race" do
    before do
      @user = create(:user)
      @race = create(:race)
    end
    
    it "should return false when user is not official for the race" do
      expect(@user).not_to have_full_rights_for_race(@race)
    end
    
    it "should return false when user has only add competitors rights" do
      @user.race_rights.create!(:race => @race, :only_add_competitors => true)
      expect(@user).not_to have_full_rights_for_race(@race)
    end
    
    it "should return true when user has full rights" do
      @user.race_rights.create!(:race => @race, :only_add_competitors => false)
      expect(@user).to have_full_rights_for_race(@race)
    end
  end
end
