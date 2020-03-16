class Batch < ApplicationRecord
  belongs_to :race

  validates :type, presence: true
  validates :number, numericality: { greater_than: 0, only_integer: true, allow_nil: false }, uniqueness: { scope: [:race_id, :type] }
  validates :track, numericality: { greater_than: 0, only_integer: true, allow_nil: true }
  validates :time, presence: true, uniqueness: { scope: [:race_id, :track, :day, :type] }
  validates :day, numericality: { greater_than: 0, only_integer: true, allow_nil: false }
  validate :day_not_too_big

  def qualification_round?
    type == 'QualificationRoundBatch'
  end

  def final_round?
    type == 'FinalRoundBatch'
  end

  private

  def day_not_too_big
    errors.add(:day, "ei voi olla suurempi kuin kilpailupäivien määrä") if race && day > race.days_count
  end
end
