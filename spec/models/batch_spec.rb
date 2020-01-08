require 'spec_helper'

RSpec.describe Batch, type: :model do
  it 'create' do
    create :batch
  end

  describe 'associations' do
    it { should belong_to(:race) }
  end

  describe 'validations' do
    it_should_behave_like 'positive integer', :number
    it_should_behave_like 'positive integer', :track
    it { should validate_presence_of(:time) }
  end
end