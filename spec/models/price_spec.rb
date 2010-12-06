require 'spec_helper'

describe Price do
  it "create" do
    Factory.create(:price)
  end

  describe "validations" do
    describe "min_competitors" do
      it { should validate_numericality_of(:min_competitors) }
      it { should_not allow_value(-1).for(:min_competitors) }
      it { should_not allow_value(0).for(:min_competitors) }
      it { should_not allow_value(1.1).for(:min_competitors) }
      it { should allow_value(1).for(:min_competitors) }
    end
    describe "price" do
      it { should validate_numericality_of(:price) }
      it { should_not allow_value(-1).for(:price) }
      it { should_not allow_value(0).for(:price) }
      it { should allow_value(0.1).for(:price) }
      it { should allow_value(1).for(:price) }
    end
  end

  describe "#price_for_competitor_amount" do
    before do
      Factory.create(:price, :min_competitors => 20, :price => 0.5)
      Factory.create(:price, :min_competitors => 1, :price => 1.5)
      Factory.create(:price, :min_competitors => 10, :price => 1.0)
    end

    specify { Price.price_for_competitor_amount(1).should == 1.5 }
    specify { Price.price_for_competitor_amount(9).should == 9 * 1.5 }
    specify { Price.price_for_competitor_amount(10).should == 10 }
    specify { Price.price_for_competitor_amount(19).should == 19 }
    specify { Price.price_for_competitor_amount(20).should == 10 }
    specify { Price.price_for_competitor_amount(100).should == 50 }
  end
end
