require 'spec_helper'

describe Sport do
  describe "find by key" do
    it 'RUN' do
      expect(Sport.by_key('RUN').name).to eq('Hirvenjuoksu')
      expect(Sport.by_key('RUN').qualification_round).to be_falsey
      expect(Sport.by_key('RUN').max_shot).to eql 10
    end

    it 'SKI' do
      expect(Sport.by_key('SKI').name).to eq('Hirvenhiihto')
      expect(Sport.by_key('SKI').qualification_round).to be_falsey
      expect(Sport.by_key('SKI').max_shot).to eql 10
    end

    it 'ILMAHIRVI' do
      expect(Sport.by_key('ILMAHIRVI').name).to eq('Ilmahirvi')
      expect(Sport.by_key('ILMAHIRVI').qualification_round).to eql [10]
      expect(Sport.by_key('ILMAHIRVI').max_shot).to eql 10
    end

    it 'ILMALUODIKKO' do
      expect(Sport.by_key('ILMALUODIKKO').name).to eq('Ilmaluodikko')
      expect(Sport.by_key('ILMALUODIKKO').qualification_round).to eql [5, 5]
      expect(Sport.by_key('ILMALUODIKKO').max_shot).to eql 11
    end
  end
end

