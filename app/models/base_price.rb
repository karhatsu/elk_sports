class BasePrice < ApplicationRecord
  validates :price, :numericality => { :only_integer => true,
    :greater_than_or_equal_to => 0 }
  validate :only_one_base_price, :on => :create

  def self.price
    BasePrice.first.price
  end

  private
  def only_one_base_price
    errors.add(:base, 'Voi olla vain yksi perushinta') if BasePrice.count > 0
  end
end
